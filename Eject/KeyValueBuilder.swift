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
        self.rvalue = BasicRValue(value: "", format: format)
    }

    func configure(parent: IBGraphable?, attributes: [String: String]) -> IBGraphable {
        guard let object = parent as? IBReference else { fatalError("No parent to configure") }
        guard let key = attributes["key"] else { fatalError("No key supplied") }
        rvalue.value = attributes["value"] ?? rvalue.value
        object.addVariableConfiguration(for: key, rvalue: rvalue)
        return object
    }

    func found(characters: String) {
        rvalue.value.append(characters)
    }

}
