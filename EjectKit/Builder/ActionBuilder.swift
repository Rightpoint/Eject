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

    func generateCode(in document: IBDocument) -> String {
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

    func buildElement(attributes: [String : String], document: IBDocument, parent: IBReference?) -> IBReference? {
        guard let parent = parent else { fatalError("No parent to configure") }
        guard let action = attributes["selector"] else { fatalError("No Action Specified") }
        guard let destination = attributes["destination"] else { fatalError("No target specified") }
        let event = attributes["eventType"]

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
