//
//  FontBuilder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct FontBuilder: Builder {

    func buildElement(attributes: [String: String], document: XIBDocument, parent: Reference?) throws -> Reference? {
        guard let parent = parent else { throw XIBParser.Error.needParent }
        guard var key = attributes["key"] else { throw XIBParser.Error.requiredAttribute(attribute: "key") }
        let value: String

        // Not sure why, but the IB specifies a private key. Fix it up.
        if key == "fontDescription" { key = "font" }
        if let type = attributes["type"], let pointSize = attributes["pointSize"] {
            value = ".\(type)Font(ofSize: \(pointSize))"
        }
        else if let pointSize = attributes["pointSize"], let name = attributes["name"] {
            value = "UIFont(name: \"\(name)\", size: \(pointSize))"
        }
        else {
            throw XIBParser.Error.unknown(attributes: attributes)
        }

        document.addVariableConfiguration(for: parent.identifier, key: key, value: BasicValue(value: value))
        return parent
    }
}
