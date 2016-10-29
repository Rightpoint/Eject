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
        attributes.removeValue(forKey: "type")
        document.containerContext = .assigmentOverride(key: keyPath)
        return parent
    }

    func complete(document: XIBDocument) {
        document.containerContext = nil
    }
}
