//
//  OptionSetBuilder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct OptionSetBuilder: Builder {

    func configure(parent: IBReference?, document: IBDocument, attributes: [String: String]) -> IBReference? {
        guard let parent = parent else { fatalError("No parent to configure") }
        var attributes = attributes
        guard let key = attributes.removeValue(forKey: "key") else {
            fatalError("Key not found in Option Set")
        }
        parent.addVariableConfiguration(for: key, value: OptionSetValue(attributes: attributes))
        return parent
    }
    
}
