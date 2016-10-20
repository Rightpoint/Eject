//
//  OptionSetBuilder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct OptionSetBuilder: Builder {

    func configure(parent: IBGraphable?, attributes: [String: String]) -> IBGraphable {
        guard let parent = parent else { fatalError("No parent to configure") }
        guard let object = parent as? IBReference else { fatalError("parent is not IBReference") }
        var attributes = attributes
        guard let key = attributes.removeValue(forKey: "key") else {
            fatalError("Key not found in Option Set")
        }
        object.addVariableConfiguration(for: key, rvalue: OptionSetRValue(attributes: attributes))
        return parent
    }
    
}
