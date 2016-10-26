//
//  AchorageConstraintBuilder.swift
//  Eject
//
//  Created by Brian King on 10/20/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct AnchorageConfiguration: CodeGenerator {
    let parentIdentifier: String
    let attributes: [String: String]

    var dependentIdentifiers: Set<String> {
        let identifiers: Set<String> = [attributes["firstItem"] ?? parentIdentifier]
        guard let second = attributes["secondItem"] else {
            return identifiers
        }
        return identifiers.union([second])
    }

    func relationshipOperator(for enumeration: String) -> String {
        switch enumeration {
        case "equal": return "=="
        case "lessThanOrEqual": return "<="
        case "greaterThanOrEqual": return ">="
        default: fatalError("Unknown operator \(enumeration)")
        }
    }

    func generateCode(in document: IBDocument) -> String {
        var constraintParts: [String] = []
        var variablePart: [String] = []
        let firstItem = attributes["firstItem"] ?? parentIdentifier
        guard let firstAttribute = attributes["firstAttribute"] else {
            fatalError("Expecting a firstAttribute")
        }
        let reference = document.lookupReference(for: firstItem)
        let variable = document.variable(for: reference)
        constraintParts.append("\(variable).\(firstAttribute)")
        variablePart.append(variable)
        variablePart.append(firstAttribute)

        let relationship = attributes["relationship"] ?? "equal"
        constraintParts.append(relationshipOperator(for: relationship))
        variablePart.append(relationship)
        var includeOperationForConstant = false

        if let item = attributes["secondItem"], let attribute = attributes["secondAttribute"] {
            let reference = document.lookupReference(for: item)
            let variable = document.variable(for: reference)
            constraintParts.append("\(variable).\(attribute)")
            variablePart.append("to")
            variablePart.append(variable)
            variablePart.append(attribute)
            includeOperationForConstant = true
        }

        if let constant = attributes["constant"]?.floatValue {
            if includeOperationForConstant {
                if constant > 0 {
                    constraintParts.append("+")
                }
                else if constant < 0 {
                    constraintParts.append("-")
                }
            }
            constraintParts.append(constant.shortString)
        }
        if let priority = attributes["priority"] {
            constraintParts.append("~ \(priority)")
        }

        let constraintCommand = constraintParts.joined(separator: " ")

        if false {
            let variableString = variablePart.joined(separator: " ").snakeCased()
            return "let \(variableString) = \(constraintCommand)"
        }
        else {
            return constraintCommand
        }
    }
}

struct AchorageConstraintBuilder: Builder {

    func buildElement(attributes: [String: String], document: IBDocument, parent: IBReference?) -> IBReference? {
        guard let parent = parent else { fatalError("No parent to configure") }
        guard let identifier = attributes["id"] else { fatalError("No id attribute") }
        let generator = AnchorageConfiguration(parentIdentifier: parent.identifier, attributes: attributes)
        _ = document.addObject(
            for: identifier,
            className: "NSLayoutConstraint",
            userLabel: attributes["userLabel"],
            declaration: .invocation(generator),
            phase: .constraints
        )
        return parent
    }

}
