//
//  ConstraintBuilder.swift
//  Eject
//
//  Created by Brian King on 10/20/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct AnchorageConfiguration: CodeGenerator {
    let identifier: String
    let first: (item: String, attr: String)
    let relationship: String
    let multiplier: String?
    let constant: String?
    let second: (item: String, attr: String)?
    let priority: String?

    var dependentIdentifiers: Set<String> {
        let identifiers: Set<String> = [first.item]
        guard let second = second else { return identifiers }
        return identifiers.union([second.item])
    }

    func relationshipOperator(for enumeration: String) -> String {
        switch enumeration {
        case "equal": return "=="
        case "lessThanOrEqual": return "<="
        case "greaterThanOrEqual": return ">="
        default: fatalError("Unknown operator \(enumeration)")
        }
    }

    func generateCode(in document: XIBDocument) throws -> String {
        var constraintParts: [String] = []
        var variablePart: [String] = []

        let reference = try document.lookupReference(for: first.item)
        let variable = document.variable(for: reference)
        constraintParts.append("\(variable).\(first.attr)Anchor")
        variablePart.append(variable)
        variablePart.append(first.attr)

        constraintParts.append(relationshipOperator(for: relationship))
        variablePart.append(relationship)
        var includeOperationForConstant = false

        if let second = second {
            let reference = try document.lookupReference(for: second.item)
            let variable = document.variable(for: reference)
            constraintParts.append("\(variable).\(second.attr)Anchor")
            variablePart.append("to")
            variablePart.append(variable)
            variablePart.append(second.attr)
            includeOperationForConstant = true
        }

        if let multiplier = multiplier {
            // IB will represent the multiplier as X:Y for aspect ratios. Convert it to math.
            constraintParts.append("* \(multiplier.replacingOccurrences(of: ":", with: "/"))")
        }

        if let constant = constant?.floatValue {
            if includeOperationForConstant {
                if constant > 0 {
                    constraintParts.append("+")
                }
                else if constant < 0 {
                    constraintParts.append("-")
                }
            }
            constraintParts.append((constant > 0 ? constant : -constant).shortString)
        }
        if let priority = priority {
            constraintParts.append("~ \(priority)")
        }

        let constraintCommand = constraintParts.joined(separator: " ")

        if document.hasDependencies(for: identifier) {
            let variableString = variablePart.joined(separator: " ").snakeCased()
            document.variableNameOverrides[identifier] = { _ in return variableString }
            return "let \(variableString) = (\(constraintCommand))"
        }
        else {
            return constraintCommand
        }
    }
}

struct ConstraintBuilder: Builder {

    func buildElement(attributes: inout [String: String], document: XIBDocument, parent: Reference?) throws -> Reference? {
        guard let parent = parent else { throw XIBParser.Error.needParent }
        let identifier = try attributes.removeRequiredValue(forKey: "id")
        let firstItem = attributes.removeValue(forKey: "firstItem") ?? parent.identifier
        let firstAttr = try attributes.removeRequiredValue(forKey: "firstAttribute")
        let relationship = attributes.removeValue(forKey: "relation") ?? "equal"
        let multiplier = attributes.removeValue(forKey: "multiplier")
        let constant = attributes.removeValue(forKey: "constant")
        let secondItem = attributes.removeValue(forKey: "secondItem")
        let secondAttr = attributes.removeValue(forKey: "secondAttribute")
        let priority = attributes.removeValue(forKey: "priority")
        attributes.removeValue(forKey: "symbolic")
        var second: (String, String)? = nil
        if let secondItem = secondItem, let secondAttr = secondAttr {
            second = (secondItem, secondAttr)
        }
        let generator = AnchorageConfiguration(
            identifier: identifier,
            first: (firstItem, firstAttr),
            relationship: relationship,
            multiplier: multiplier,
            constant: constant,
            second: second,
            priority: priority
        )

        let constraint = document.addObject(
            for: identifier,
            className: "NSLayoutConstraint",
            userLabel: attributes.removeValue(forKey: "userLabel"),
            declaration: .invocation(generator, .constraints)
        )
        return constraint
    }

}
