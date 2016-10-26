//
//  OptionSetBuilder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct OptionSetBuilder: Builder {

    func buildElement(attributes: [String: String], document: XIBDocument, parent: Reference?) -> Reference? {
        guard let parent = parent else { fatalError("No parent to configure") }
        var attributes = attributes
        guard let key = attributes.removeValue(forKey: "key") else {
            fatalError("Key not found in Option Set")
        }
        document.addVariableConfiguration(for: parent.identifier, key: key, value: OptionSetValue(attributes: attributes))
        return parent
    }
    
}
