//
//  ConstraintCodeGenerator.swift
//  Eject
//
//  Created by Brian King on 11/12/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

protocol ConstraintCodeGenerator: CodeGenerator {
    static var needsPriorityConfigurationCommand: Bool { get }
    init(constraintState: ConstraintState)
    var constraintState: ConstraintState { get }
}

extension ConstraintConfiguration {
    var generator: ConstraintCodeGenerator.Type {
        switch self {
        case .anchorage:
            return AnchorageConfiguration.self
        case .anchor:
            return AnchorConfiguration.self
        }
    }
}

extension ConstraintCodeGenerator {

    var dependentIdentifiers: Set<String> {
        let identifiers: Set<String> = [constraintState.first.item]
        guard let second = constraintState.second else { return identifiers }
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

    func variableName(in document: XIBDocument) throws -> String {
        var variablePart: [String] = []
        let reference = try document.lookupReference(for: constraintState.first.item)
        variablePart.append(document.variable(for: reference))
        variablePart.append(constraintState.first.attr)
        variablePart.append(constraintState.relationship)

        if let second = constraintState.second {
            let reference = try document.lookupReference(for: second.item)
            let variable = document.variable(for: reference)
            variablePart.append("to")
            variablePart.append(variable)
            variablePart.append(second.attr)
        }

        let variableString = variablePart.joined(separator: " ").snakeCased()
        return variableString
    }
}

struct AnchorageConfiguration: ConstraintCodeGenerator {
    let constraintState: ConstraintState

    static var needsPriorityConfigurationCommand: Bool {
        return false
    }

    func generateCode(in document: XIBDocument) throws -> String? {
        var constraintParts: [String] = []

        let reference = try document.lookupReference(for: constraintState.first.item)
        let variable = document.variable(for: reference)
        constraintParts.append("\(variable).\(constraintState.first.attr)Anchor")
        constraintParts.append(relationshipOperator(for: constraintState.relationship))
        var includeOperationForConstant = false

        if let second = constraintState.second {
            let reference = try document.lookupReference(for: second.item)
            let variable = document.variable(for: reference)
            constraintParts.append("\(variable).\(second.attr)Anchor")
            includeOperationForConstant = true
        }

        if let multiplier = constraintState.multiplier {
            // IB will represent the multiplier as X:Y for aspect ratios. Convert it to math.
            constraintParts.append("* \(multiplier.replacingOccurrences(of: ":", with: "/"))")
        }

        if let constant = constraintState.constant?.floatValue {
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
        if let priority = constraintState.priority {
            constraintParts.append("~ \(priority)")
        }

        let constraintCommand = constraintParts.joined(separator: " ")

        if document.hasDependencies(for: constraintState.identifier) {
            let variableString = try variableName(in: document)
            document.variableNameOverrides[constraintState.identifier] = { _ in variableString  }
            return "let \(variableString) = (\(constraintCommand))"
        }
        else {
            return constraintCommand
        }
    }
}

struct AnchorConfiguration: ConstraintCodeGenerator {

    let constraintState: ConstraintState

    static var needsPriorityConfigurationCommand: Bool {
        return true
    }

    func generateCode(in document: XIBDocument) throws -> String? {
        let reference = try document.lookupReference(for: constraintState.first.item)
        let variable = document.variable(for: reference)
        var cmd = "\(variable).\(constraintState.first.attr)Anchor"
        cmd.append(".constraint(")
        cmd.append(constraintState.relationship.appending("To"))

        if let second = constraintState.second {
            let reference = try document.lookupReference(for: second.item)
            let variable = document.variable(for: reference)
            cmd.append(": \(variable).\(second.attr)Anchor")
        }

        if let constant = constraintState.constant?.floatValue {
            if constraintState.second == nil {
                cmd.append("Constant: \(constant)")
            }
            else {
                cmd.append(", constant: \(constant)")
            }
        }
        if let multiplier = constraintState.multiplier?.replacingOccurrences(of: ":", with: " / ") {
            // IB will represent the multiplier as X:Y for aspect ratios. Convert it to math.
            cmd.append(", multiplier: \(multiplier)")
        }
        cmd.append(")")

        if document.hasDependencies(for: constraintState.identifier) {
            let variableString = try variableName(in: document)
            document.variableNameOverrides[constraintState.identifier] = { _ in variableString  }
            return "let \(variableString) = (\(cmd))"
        }
        else {
            // active = true is added if there are dependencies.
            cmd.append(".isActive = true")
            return cmd
        }
    }
}
