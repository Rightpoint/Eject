//
//  ActionBuilder.swift
//  Eject
//
//  Created by Brian King on 10/20/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct TargetActionConfiguration: CodeGenerator {
    let objectIdentifier: String
    let targetIdentifier: String
    let action: String
    let event: String?

    var dependentIdentifiers: Set<String> {
        return [objectIdentifier, targetIdentifier]
    }

    func generateCode(in document: XIBDocument) throws -> String? {
        let object = try document.lookupReference(for: objectIdentifier)
        let variable = document.variable(for: object)
        let target = try document.lookupReference(for: targetIdentifier)
        let targetVariable = document.variable(for: target)
        let representation: String
        if let event = event {
            representation = "\(variable).addTarget(\(targetVariable), action: #selector(\(target.className).\(action)), for: .\(event))"
        }
        else {
            representation = "\(variable).addTarget(\(targetVariable), action: #selector(\(target.className).\(action)))"
        }
        return representation
    }
}


struct ActionBuilder: Builder {

    func buildElement(attributes: inout [String : String], document: XIBDocument, parent: Reference?) throws -> Reference? {
        guard let parent = parent else { throw XIBParser.Error.needParent }
        var action = try attributes.removeRequiredValue(forKey: "selector")
        let destination = try attributes.removeRequiredValue(forKey: "destination")
        let event = attributes.removeValue(forKey: "eventType")
        attributes.removeValue(forKey: "id")
        if !action.contains("("), let range = action.range(of: ":") {
            action.replaceSubrange(range, with: "(_:)")
        }

        try document.addStatement(
            for: parent.identifier,
            generator: TargetActionConfiguration(
                objectIdentifier: parent.identifier,
                targetIdentifier: destination,
                action: action,
                event: event
            ),
            phase: .configuration)
        return parent
    }
}
