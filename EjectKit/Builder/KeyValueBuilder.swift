//
//  NilBuilder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation


struct KeyValueBuilder: Builder, CharacterBuilder {
    let rvalue: BasicRValue

    init(value: String = "", format: RValueFormat = .raw) {
        self.rvalue = BasicRValue(value: value, format: format)
    }

    func configure(parent: IBReference?, document: IBDocument, attributes: [String: String]) -> IBReference? {
        guard let object = parent else { fatalError("No parent to configure") }
        guard let key = attributes["key"] else { fatalError("No key supplied") }
        rvalue.value = attributes["value"] ?? rvalue.value
        object.addVariableConfiguration(for: key, rvalue: rvalue)
        return object
    }

    func found(characters: String) {
        rvalue.value.append(characters)
    }

}
