//
//  ConstraintBuilder.swift
//  Eject
//
//  Created by Brian King on 10/20/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct ConstraintState {
    let identifier: String
    let first: (item: String, attr: String)
    let relationship: String
    let multiplier: String?
    let constant: String?
    let second: (item: String, attr: String)?
    let priority: String?
}

struct ConstraintBuilder: Builder {

    func buildElement(attributes: inout [String: String], document: XIBDocument, parent: Reference?) throws -> Reference? {
        guard let parent = parent else { throw XIBParser.Error.needParent }
        let identifier = try attributes.removeRequiredValue(forKey: "id")
        let firstItem = attributes.removeValue(forKey: "firstItem") ?? parent.identifier
        let firstAttr = try attributes.removeRequiredValue(forKey: "firstAttribute")
        let relationship = attributes.removeValue(forKey: "relation") ?? "equal"
        var multiplier = attributes.removeValue(forKey: "multiplier")
        let constant = attributes.removeValue(forKey: "constant")
        let secondItem = attributes.removeValue(forKey: "secondItem")
        let secondAttr = attributes.removeValue(forKey: "secondAttribute")
        let priority = attributes.removeValue(forKey: "priority")
        attributes.removeValue(forKey: "symbolic")
        var second: (String, String)? = nil
        if let secondItem = secondItem, let secondAttr = secondAttr {
            second = (secondItem, secondAttr)
        }
        if multiplier  == "1" || multiplier == "1:1" {
            multiplier = nil
        }
        let constraintState = ConstraintState(
            identifier: identifier,
            first: (firstItem, firstAttr),
            relationship: relationship,
            multiplier: multiplier,
            constant: constant,
            second: second,
            priority: priority
        )

        let generator = document.configuration.constraint.generator.init(constraintState: constraintState)

        let constraint = document.addObject(
            for: identifier,
            definition: ObjectDefinition(className: "NSLayoutConstraint"),
            customSubclass: nil,
            userLabel: attributes.removeValue(forKey: "userLabel")
        )
        try document.addStatement(for: identifier, generator: generator, phase: .constraints)

        if let priority = constraintState.priority, document.configuration.constraint.generator.needsPriorityConfigurationCommand {
            try document.addVariableConfiguration(
                for: constraintState.identifier,
                attribute: "priority",
                value: BasicValue(value: priority, format: .number),
                phase: .constraints
            )
            try document.addVariableConfiguration(
                for: constraintState.identifier,
                attribute: "isActive",
                value: BasicValue(value: "YES", format: .boolean),
                phase: .constraints
            )
        }

        return constraint
    }

}
