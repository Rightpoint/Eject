//
//  UserDefinedRuntimeAttributesBuilder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct UserDefinedAttributeBuilder: Builder {

    func buildElement(attributes: [String: String], document: IBDocument, parent: IBReference?) -> IBReference? {
        guard let parent = parent else { fatalError("No parent to configure") }
        guard let keyPath = attributes["keyPath"] else { fatalError("No keypath") }
        document.containerContext = .assigmentOverride(key: keyPath)
        return parent
    }

    func complete(document: IBDocument) {
        document.containerContext = nil
    }
}
