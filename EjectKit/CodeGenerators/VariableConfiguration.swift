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
    let style: AssociationContext

    var dependentIdentifiers: Set<String> {
        let identifiers: Set<String> = [objectIdentifier]
        return identifiers.union(value.dependentIdentifiers)
    }

    func generateCode(in document: XIBDocument) throws -> String? {
        let object = try document.lookupReference(for: objectIdentifier)
        let variable = document.variable(for: object)

        if let valueString = try value.generateCode(in: document) {
            return style.generateCommand(variable: variable, key: key, valueString: valueString)
        }
        else {
            return nil
        }
    }
}

private extension AssociationContext {

    func generateCommand(variable: String, key: String, valueString: String) -> String {
        switch self {
        case .assignment:
            return "\(variable).\(key) = \(valueString)"
        case .append:
            return "\(variable).\(key).append(\(valueString))"
        case let .setter(context):
            let label = "set \(key)".snakeCased()
            return "\(variable).\(label)(\(valueString), \(context))"
        case let .invocation(prefix, suffix, includeTag):
            if includeTag {
                return "\(variable).\(prefix)\(key): \(valueString)\(suffix)"
            }
            else {
                return "\(variable).\(prefix)\(valueString)\(suffix)"
            }
        case let .withComment(comment, style):
            let command = style.generateCommand(variable: variable, key: key, valueString: valueString)
            return "\(command) // \(comment)"
        case .ignore:
            fatalError("`.ignore` should never be configured on a VariableContext")
        case .inject:
            fatalError("`.inject` should never be configured on a VariableContext")
        case .placeholder:
            fatalError("`.placeholder` should never be configured on a VariableContext")
        }
    }
}
