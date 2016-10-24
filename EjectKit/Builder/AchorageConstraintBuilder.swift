//
//  AchorageConstraintBuilder.swift
//  Eject
//
//  Created by Brian King on 10/20/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct AnchorageConfiguration: ObjectCodeGenerator {
    let parentIdentifier: String
    let attributes: [String: String]

    func generationPhase(in document: IBDocument) -> ObjectGenerationPhase {
        return .constraints
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
        let firstItem = attributes["firstItem"] ?? parentIdentifier
        guard let firstAttribute = attributes["firstAttribute"] else {
            fatalError("Expecting a firstAttribute")
        }
        let reference = document.lookupReference(for: firstItem)
        let variable = document.variable(for: reference)
        constraintParts.append("\(variable).\(firstAttribute)")

        let relationship = attributes["relationship"] ?? "equal"
        constraintParts.append(relationshipOperator(for: relationship))
        var includeOperationForConstant = false

        if let item = attributes["secondItem"], let attribute = attributes["secondAttribute"] {
            let reference = document.lookupReference(for: item)
            let variable = document.variable(for: reference)
            constraintParts.append("\(variable).\(attribute)")
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

        return constraintParts.joined(separator: " ")
    }
}

struct AchorageConstraintBuilder: Builder {

    func configure(parent: IBReference?, document: IBDocument, attributes: [String: String]) -> IBReference? {
        guard let parent = parent else { fatalError("No parent to configure") }
        parent.generators.append(AnchorageConfiguration(parentIdentifier: parent.identifier, attributes: attributes))
        return parent
    }

}
