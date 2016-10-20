//
//  Generators.swift
//  Eject
//
//  Created by Brian King on 10/17/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct VariableConfiguration: ObjectCodeGenerator {
    var objectIdentifier: String
    var key: String = ""
    var value: CodeGenerator
    // This bit of information adds support for `forState: .touchUpInside`
    var setterContext: String? = nil

    func generationPhase(in context: GenerationContext) -> ObjectGenerationPhase {
        return .configuration
    }

    func generateCode(in context: GenerationContext) -> String? {
        let document = context.document
        let object = document.lookupReference(for: objectIdentifier)
        let variable = document.variable(for: object)
        if let setterContext = setterContext {
            return "\(variable).set\(key.capitalized)(\(value.generateCode(in: context) ?? "<ERROR>"), \(setterContext))"
        }
        else {
            return "\(variable).\(key) = \(value.generateCode(in: context) ?? "<ERROR>")"
        }
    }
}

struct Declaration: ObjectCodeGenerator {
    let objectIdentifier: String
    let className: String
    let arguments: [String: String]

    func generationPhase(in context: GenerationContext) -> ObjectGenerationPhase {
        let document = context.document
        let object = document.lookupReference(for: objectIdentifier)
        let scope = document.scope(for: object)
        switch scope {
        case .local:
            return .scopeVariable
        case .property:
            return .properties
        }
    }

    func generateCode(in context: GenerationContext) -> String? {
        let document = context.document
        let object = document.lookupReference(for: objectIdentifier)
        let variable = document.variable(for: object)
        let argumentString = arguments.map() { "\($0): \($1)" }.joined(separator: ", ")
        return "let \(variable) = \(className)(\(argumentString))"
    }
    
}
