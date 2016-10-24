//
//  AutoresizingMaskBuilder.swift
//  Eject
//
//  Created by Brian King on 10/24/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct AutoresizingMaskBuilder: Builder {

    func configure(parent: IBReference?, document: IBDocument, attributes: [String: String]) -> IBReference? {
        guard let parent = parent else { fatalError("No parent to configure") }
        guard attributes["key"] == "autoresizingMask" else { fatalError("Invalid Key") }

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
                fatalError("Unknown Key '\(key)'")
            }
        }
        parent.addVariableConfiguration(for: "autoresizingMask", value: OptionSetValue(attributes: values))
        return parent
    }
}
