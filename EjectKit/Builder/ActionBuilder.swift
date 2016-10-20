//
//  ActionBuilder.swift
//  Eject
//
//  Created by Brian King on 10/20/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct TargetActionConfiguration: ObjectCodeGenerator {
    let objectIdentifier: String
    let targetIdentifier: String
    let action: String
    let event: String?

    func generationPhase(in context: GenerationContext) -> ObjectGenerationPhase {
        return .subviews
    }

    func generateCode(in context: GenerationContext) -> String? {
        let document = context.document
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

    func configure(parent: IBReference?, document: IBDocument, attributes: [String : String]) -> IBReference? {
        guard let parent = parent else { fatalError("No parent to configure") }
        guard let action = attributes["selector"] else { fatalError("No Action Specified") }
        guard let destination = attributes["destination"] else { fatalError("No target specified") }
        let event = attributes["eventType"]

        parent.generators.append(
            TargetActionConfiguration(
                objectIdentifier: parent.identifier,
                targetIdentifier: destination,
                action: action,
                event: event
            )
        )
        return parent
    }
}
