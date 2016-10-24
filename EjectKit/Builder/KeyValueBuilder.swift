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

    func configure(parent: IBReference?, document: IBDocument, attributes: [String: String]) -> IBReference? {
        guard let object = parent else { fatalError("No parent to configure") }
        guard let key = attributes["key"] else { fatalError("No key supplied") }
        value.value = attributes["value"] ?? value.value
        object.addVariableConfiguration(for: key, value: value)
        return object
    }

    func found(characters: String) {
        value.value.append(characters)
    }

}
