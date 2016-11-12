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
    let ignoredKeys: [String]

    init(value: String = "", format: ValueFormat = .raw, ignoredKeys: [String] = []) {
        self.value = BasicValue(value: value, format: format)
        self.ignoredKeys = ignoredKeys
    }

    func buildElement(attributes: inout [String: String], document: XIBDocument, parent: Reference?) throws -> Reference? {
        if let parent = parent {
            let key = try attributes.removeRequiredValue(forKey: "key")
            guard !ignoredKeys.contains(key) else { return parent }
            value.value = attributes.removeValue(forKey: "value") ?? value.value
            try document.addVariableConfiguration(for: parent.identifier, key: key, value: value)
        }
        return parent
    }

    func found(characters: String) {
        value.value.append(characters)
    }

}
