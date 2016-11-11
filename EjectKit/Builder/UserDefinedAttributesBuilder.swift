//
//  UserDefinedRuntimeAttributesBuilder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct UserDefinedAttributeBuilder: Builder {

    func buildElement(attributes: inout [String: String], document: XIBDocument, parent: Reference?) throws -> Reference? {
        guard let parent = parent else { throw XIBParser.Error.needParent }
        let keyPath = try attributes.removeRequiredValue(forKey: "keyPath")
        let type = attributes.removeValue(forKey: "type")
        if let value = attributes.removeValue(forKey: "value") {
            guard type == "boolean" else {
                throw XIBParser.Error.unknown(attributes: attributes)
            }
            try document.addVariableConfiguration(
                for: parent.identifier,
                key: keyPath,
                value: BasicValue(value: value, format: .boolean),
                context: .assignment
            )
        }
        else {
            document.keyOverride = keyPath
        }
        return parent
    }

    func complete(document: XIBDocument) {
        document.keyOverride = nil
    }
}
