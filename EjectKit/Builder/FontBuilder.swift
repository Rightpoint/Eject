//
//  FontBuilder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct FontBuilder: Builder {

    func buildElement(attributes: inout [String: String], document: XIBDocument, parent: Reference?) throws -> Reference? {
        guard let parent = parent else { throw XIBParser.Error.needParent }
        var key = try attributes.removeRequiredValue(forKey: "key")
        let pointSize = try attributes.removeRequiredValue(forKey: "pointSize")
        let value: String
        attributes.removeValue(forKey: "family")

        // Not sure why, but the IB specifies a private key. Fix it up.
        if key == "fontDescription" { key = "font" }
        if let type = attributes.removeValue(forKey: "type") {
            value = ".\(type)Font(ofSize: \(pointSize))"
        }
        else if let name = attributes.removeValue(forKey: "name") {
            value = "UIFont(name: \"\(name)\", size: \(pointSize))"
        }
        else {
            throw XIBParser.Error.unknown(attributes: attributes)
        }

        document.addVariableConfiguration(
            for: parent.identifier,
            key: key,
            value: BasicValue(value: value)
        )
        return parent
    }
}
