//
//  AutoresizingMaskBuilder.swift
//  Eject
//
//  Created by Brian King on 10/24/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct AutoresizingMaskBuilder: Builder {

    func buildElement(attributes: inout [String: String], document: XIBDocument, parent: Reference?) throws -> Reference? {
        guard let parent = parent else { throw XIBParser.Error.needParent }
        guard attributes.removeValue(forKey: "key") == "autoresizingMask" else { throw XIBParser.Error.unknown(attributes: attributes) }

        var values: [String: String] = [:]
        for (key, value) in attributes {
            guard value == "YES" else { continue }
            switch key {
            case "flexibleMaxY":
                values["flexibleTopMargin"] = value
            case "flexibleMinY":
                values["flexibleBottomMargin"] = value
            case "flexibleMaxX":
                values["flexibleRightMargin"] = value
            case "flexibleMinX":
                values["flexibleLeftMargin"] = value
            case "widthSizable":
                values["flexibleWidth"] = value
            case "heightSizable":
                values["flexibleHeight"] = value
            default:
                throw XIBParser.Error.unknown(attributes: attributes)
            }
        }
        try document.addVariableConfiguration(
            for: parent.identifier,
            attribute: "autoresizingMask",
            value: OptionSetValue(attributes: values)
        )
        // Remove all the keys, any unknown state should be caught above.
        attributes.removeAll()
        return parent
    }
}
