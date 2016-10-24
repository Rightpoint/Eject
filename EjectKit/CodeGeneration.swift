//
//  ObjectCodeGenerator.swift
//  Eject
//
//  Created by Brian King on 10/18/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

public protocol CodeGenerator {
    func generateCode(in document: IBDocument) -> String
}

public enum ObjectGenerationPhase {
    case properties
    case scopeVariable
    case configuration
    case subviews
    case constraints
}

public protocol ObjectCodeGenerator: CodeGenerator {
    func generationPhase(in document: IBDocument) -> ObjectGenerationPhase
}

public extension IBReference {

    func generateCode(in document: IBDocument, for generationPhase: ObjectGenerationPhase) -> [String] {
        return generators
            .filter() { $0.generationPhase(in: document) == generationPhase }
            .map() { $0.generateCode(in: document) }
            .flatMap() { $0 }
    }

    func generateCodeForConfiguration(in document: IBDocument) -> [String] {
        var declaration = generateCode(in: document, for: .scopeVariable)
        declaration.append(contentsOf: generateCode(in: document, for: .configuration))
        return declaration
    }
}

public extension IBDocument {

    func generateCode(for generationPhase: ObjectGenerationPhase) -> [String] {
        return references
            .map() { $0.generateCode(in: self, for: generationPhase) }
            .flatMap() { $0 }
    }

    func generateCodeForConfiguration() -> [String] {
        return references
            .map() { $0.generateCodeForConfiguration(in: self) }
            .flatMap() { $0 }
    }
}
