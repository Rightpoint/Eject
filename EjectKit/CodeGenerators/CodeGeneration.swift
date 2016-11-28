//
//  CodeGenerator.swift
//  Eject
//
//  Created by Brian King on 10/18/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

public protocol CodeGenerator {

    /// A set of all identifiers that are dependent on this generator.
    var dependentIdentifiers: Set<String> { get }

    /// Return a line of code, or nil if nothing should be done.
    func generateCode(in document: XIBDocument) throws -> String?

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

    func code(for generationPhase: CodeGeneratorPhase) throws -> [String] {
        return try statements.filter() { $0.phase == generationPhase }.map() { try $0.generator.generateCode(in: self) }.flatMap { $0 }
    }

    public func generateCode(disableComments: Bool = false) throws -> [String] {
        var context = GenerationContext(document: self, disableComments: disableComments)
        return try context.generateCode()
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

    mutating func declaration(identifier: String) throws -> String? {
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
        return try declaration.generator.generateCode(in: document)
    }

    mutating func configuration(identifier: String) throws -> [String] {
        // get statements that only depend on the specified object
        let configurations = extractStatements() {
            $0.generator.dependentIdentifiers == Set([identifier]) && $0.phase == .configuration
        }
        let code = try configurations.map() { try $0.generator.generateCode(in: document) }.flatMap { $0 }
        return code
    }

    mutating func code(for generationPhase: CodeGeneratorPhase) throws -> [String] {
        let code = try extractStatements() { $0.phase == generationPhase }
            .reversed()
            .map() { try $0.generator.generateCode(in: document) }
            .flatMap { $0 }
        return code
    }

    mutating func generateCode() throws -> [String] {
        var generatedCode: [String] = []
        // Generate the list of objects that need generation. This will remove the
        // placeholders since they are declared externally.
        var needGeneration = document.references.filter() { !$0.identifier.hasPrefix("-") }
        if !disableComments { generatedCode.append(CodeGeneratorPhase.initialization.comment) }
        while needGeneration.count > 0 {
            var removedIndexes = IndexSet()
            for (index, reference) in needGeneration.enumerated() {
                if let code = try declaration(identifier: reference.identifier) {
                    generatedCode.append(code)
                    let configuration = try self.configuration(identifier: reference.identifier)
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
            let lines = try code(for: phase)
            if lines.count > 0 {
                if !disableComments { generatedCode.append(phase.comment) }
                generatedCode.append(contentsOf: lines)
                generatedCode.append("")
            }
        }
        if generatedCode.last == "" {
            generatedCode.removeLast()
        }
        return generatedCode
    }
}
