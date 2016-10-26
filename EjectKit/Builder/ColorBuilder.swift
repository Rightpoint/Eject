//
//  ColorBuilder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct ColorBuilder: Builder {

    func buildElement(attributes: [String: String], document: XIBDocument, parent: Reference?) throws -> Reference? {
        guard let parent = parent else { throw XIBParser.Error.needParent }
        guard let key = attributes["key"] else { throw XIBParser.Error.requiredAttribute(attribute: "key") }
        let alpha = attributes["alpha"]?.floatValue ?? 1
        let value: String
        if let white = attributes["white"]?.floatValue {
            value = "UIColor(white: \(white.shortString), alpha: \(alpha.shortString))"
        }
        else if
            let red = attributes["red"]?.floatValue,
            let green = attributes["green"]?.floatValue,
            let blue = attributes["blue"]?.floatValue {
            value = "UIColor(red: \(red.shortString), green: \(green.shortString), blue: \(blue.shortString), alpha: \(alpha.shortString))"
        }
        else if var systemColor = attributes["cocoaTouchSystemColor"] {
            if let range = systemColor.range(of: "Color") {
                systemColor.removeSubrange(range)
            }
            value = "UIColor.\(systemColor)"
        }
        else {
            throw XIBParser.Error.unknown(attributes: attributes)
        }
        document.addVariableConfiguration(for: parent.identifier, key: key, value: BasicValue(value: value))
        return parent
    }
}
