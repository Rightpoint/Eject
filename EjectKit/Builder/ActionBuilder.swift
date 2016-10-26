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

    func generateCode(in document: XIBDocument) -> String {
        let object = document.lookupReference(for: objectIdentifier)
        let variable = document.variable(for: object)
        let target = document.lookupReference(for: targetIdentifier)
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

    func buildElement(attributes: [String : String], document: XIBDocument, parent: Reference?) throws -> Reference? {
        guard let parent = parent else { throw XIBParser.Error.needParent }
        guard var action = attributes["selector"] else { throw XIBParser.Error.requiredAttribute(attribute: "selector") }
        guard let destination = attributes["destination"] else { throw XIBParser.Error.requiredAttribute(attribute: "destination") }
        let event = attributes["eventType"]

        if !action.contains("("), let range = action.range(of: ":") {
            action.replaceSubrange(range, with: "(_:)")
        }

        document.addStatement(
            TargetActionConfiguration(
                objectIdentifier: parent.identifier,
                targetIdentifier: destination,
                action: action,
                event: event
            ),
            phase: .configuration)
        return parent
    }
}
