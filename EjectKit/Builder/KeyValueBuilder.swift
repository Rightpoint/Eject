//
//  NilBuilder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation


struct KeyValueBuilder: Builder, CharacterBuilder {
    let value: BasicValue

    init(value: String = "", format: ValueFormat = .raw) {
        self.value = BasicValue(value: value, format: format)
    }

    func buildElement(attributes: [String: String], document: XIBDocument, parent: Reference?) throws -> Reference? {
        guard let parent = parent else { throw XIBParser.Error.needParent }
        guard let key = attributes["key"] else { throw XIBParser.Error.requiredAttribute(attribute: "key") }
        value.value = attributes["value"] ?? value.value
        document.addVariableConfiguration(for: parent.identifier, key: key, value: value)
        return parent
    }

    func found(characters: String) {
        value.value.append(characters)
    }

}
