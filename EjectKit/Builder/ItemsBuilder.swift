//
//  ItemsBuilder.swift
//  Eject
//
//  Created by Brian King on 11/29/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct ItemsBuilder: Builder, ContainerBuilder {

    func buildElement(attributes: inout [String: String], document: XIBDocument, parent: Reference?) throws -> Reference? {
        guard let parent = parent else { throw XIBParser.Error.needParent }
        return parent
    }

    func didAddChild(object: Reference, to parent: Reference, document: XIBDocument) throws {
        guard !document.placeholders.contains(object.identifier) else {
            // If the object is a placeholder, assume that it has already been added to the view hierarchy.
            return
        }
        try document.addStatement(
            for: object.identifier,
            generator: VariableConfiguration(
                objectIdentifier: parent.identifier,
                key: "items",
                value: VariableValue(objectIdentifier: object.identifier),
                style: .append
            ),
            phase: .generalAssignment
        )
    }
    
}
