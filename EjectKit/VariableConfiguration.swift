//
//  VariableConfiguration.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

struct VariableConfiguration: CodeGenerator {
    let objectIdentifier: String
    let key: String
    let value: CodeGenerator
    let style: ConfigurationContext

    var dependentIdentifiers: Set<String> {
        let identifiers: Set<String> = [objectIdentifier]
        return identifiers.union(value.dependentIdentifiers)
    }

    func generateCode(in document: XIBDocument) throws -> String {
        let object = try document.lookupReference(for: objectIdentifier)
        let variable = document.variable(for: object)

        let valueString = try value.generateCode(in: document)
        return style.generateCommand(variable: variable, key: key, valueString: valueString)
    }
}

extension ConfigurationContext {

    func generateCommand(variable: String, key: String, valueString: String) -> String {
        switch self {
        case .assignment:
            return "\(variable).\(key) = \(valueString)"
        case .append:
            return "\(variable).\(key).append(\(valueString))"
        case .addIsPrefix:
            return "\(variable).\("is \(key)".snakeCased()) = \(valueString)"
        case let .assigmentOverride(key):
            return "\(variable).\(key) = \(valueString)"
        case let .setter(context):
            let label = "set \(key)".snakeCased()
            return "\(variable).\(label)(\(valueString), \(context))"
        case let .invocation(prefix, suffix):
            return "\(variable).\(prefix)\(valueString)\(suffix)"
        case let .withComment(comment, style):
            let command = style.generateCommand(variable: variable, key: key, valueString: valueString)
            return "\(command) // \(comment)"
        }
    }
}
