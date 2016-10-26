//
//  OptionSetBuilder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct OptionSetBuilder: Builder {

    func buildElement(attributes: [String: String], document: XIBDocument, parent: Reference?) throws -> Reference? {
        guard let parent = parent else { throw XIBParser.Error.needParent }
        var attributes = attributes
        guard let key = attributes.removeValue(forKey: "key") else { throw XIBParser.Error.requiredAttribute(attribute: "key") }

        document.addVariableConfiguration(for: parent.identifier, key: key, value: OptionSetValue(attributes: attributes))
        return parent
    }
    
}
