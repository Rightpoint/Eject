//
//  CodeGenerator.swift
//  Eject
//
//  Created by Brian King on 10/18/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

public protocol CodeGenerator {

    var dependentIdentifiers: Set<String> { get }

    func generateCode(in document: XIBDocument) -> String

}

extension CodeGenerator {
    var dependentIdentifiers: Set<String> {
        return []
    }
}

public enum CodeGeneratorPhase {
    case initialization
    case configuration
    case subviews
    case constraints

    var comment: String {
        switch self {
        case .initialization:
            return "// Create Views"
        case .configuration:
            return "// Remaining Configuration"
        case .subviews:
            return "// Assemble View Hierarchy"
        case .constraints:
            return "// Configure Constraints"
        }
    }
}

extension XIBDocument {

    func code(for generationPhase: CodeGeneratorPhase) -> [String] {
        return statements.filter() { $0.phase == generationPhase }.map() { $0.generator.generateCode(in: self) }
    }

    public func generateCode(disableComments: Bool = false) -> [String] {
        var context = GenerationContext(document: self, disableComments: disableComments)
        return context.generateCode()
    }
}

struct GenerationContext {
    let document: XIBDocument
    let disableComments: Bool
    var statements: [Statement]
    var declared = Set<String>()


    init(document: XIBDocument, disableComments: Bool) {
        self.document = document
        self.statements = document.statements
        self.disableComments = disableComments
    }

    mutating func extractStatements(matching: (Statement) -> Bool) -> [Statement] {
        let matching = statements.enumerated().filter() { matching($0.element) }
        matching.reversed().map() { $0.offset }.forEach() { index in
            statements.remove(at: index)
        }
        return matching.map() { $0.element }
    }

    mutating func declaration(identifier: String) -> String? {
        let declarations = extractStatements() { $0.declares?.identifier == identifier && $0.phase == .initialization }
        guard declarations.count <= 1 else {
            fatalError("Should only have one statement to declare an identifier")
        }
        guard let declaration = declarations.first else {
            // It's valid for external references (placholders) to be un-declared
            return nil
        }

        if !declaration.generator.dependentIdentifiers.isSubset(of: declared) {
            return nil
        }
        declared.insert(declaration.declares!.identifier)
        return declaration.generator.generateCode(in: document)
    }

    mutating func configuration(identifier: String) -> [String] {
        // get statements that only depend on the specified object
        let configurations = extractStatements() {
            $0.generator.dependentIdentifiers == Set([identifier]) && $0.phase == .configuration
        }
        let code = configurations.map() { $0.generator.generateCode(in: document) }
        return code
    }

    mutating func code(for generationPhase: CodeGeneratorPhase) -> [String] {
        let code = extractStatements() { $0.phase == generationPhase }
            .reversed()
            .map() { $0.generator.generateCode(in: document) }
        return code
    }

    mutating func generateCode() -> [String] {
        var generatedCode: [String] = []
        // Generate the list of objects that need generation. This will remove the
        // placeholders since they are declared externally.
        var needGeneration = document.references.filter() { !$0.identifier.hasPrefix("-") }
        if !disableComments { generatedCode.append(CodeGeneratorPhase.initialization.comment) }
        while needGeneration.count > 0 {
            var removedIndexes = IndexSet()
            for (index, reference) in needGeneration.enumerated() {
                if let code = declaration(identifier: reference.identifier) {
                    generatedCode.append(code)
                    let configuration = self.configuration(identifier: reference.identifier)
                    if configuration.count > 0 {
                        generatedCode.append(contentsOf: configuration)
                        generatedCode.append("")
                    }
                    removedIndexes.insert(index)
                }
            }
            if removedIndexes.count == 0 {
                break
            }
            for index in removedIndexes.reversed() {
                needGeneration.remove(at: index)
            }
        }
        for phase: CodeGeneratorPhase in [.subviews, .constraints, .configuration] {
            let lines = code(for: phase)
            if lines.count > 0 {
                if !disableComments { generatedCode.append(phase.comment) }
                generatedCode.append(contentsOf: lines)
                generatedCode.append("")
            }
        }
        assert(statements.count == 0)
        if generatedCode.last == "" {
            generatedCode.removeLast()
        }
        return generatedCode
    }
}
