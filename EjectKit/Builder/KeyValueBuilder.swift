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

    func buildElement(attributes: [String: String], document: XIBDocument, parent: Reference?) -> Reference? {
        guard let object = parent else { fatalError("No parent to configure") }
        guard let key = attributes["key"] else { fatalError("No key supplied") }
        value.value = attributes["value"] ?? value.value
        document.addVariableConfiguration(for: object.identifier, key: key, value: value)
        return object
    }

    func found(characters: String) {
        value.value.append(characters)
    }

}
