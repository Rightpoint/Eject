//
//  ColorBuilder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct ColorBuilder: Builder {

    func buildElement(attributes: inout [String: String], document: XIBDocument, parent: Reference?) throws -> Reference? {
        guard let parent = parent else { throw XIBParser.Error.needParent }
        var key = try attributes.removeRequiredValue(forKey: "key")
        if key == "highlightedColor" { key = "highlightedTextColor" }
        let alpha = try attributes.removeFloatString(forKey: "alpha") ?? "1"
        attributes.removeValue(forKey: "colorSpace")
        attributes.removeValue(forKey: "customColorSpace")
        let value: String
        if let white = try attributes.removeOptionalFloat(forKey: "white") {
            value = "UIColor(white: \(white.shortString), alpha: \(alpha))"
        }
        else if
            let red = try attributes.removeFloatString(forKey: "red"),
            let green = try attributes.removeFloatString(forKey: "green"),
            let blue = try attributes.removeFloatString(forKey: "blue") {
            value = "UIColor(red: \(red), green: \(green), blue: \(blue), alpha: \(alpha))"
        }
        else if var systemColor = attributes.removeValue(forKey: "cocoaTouchSystemColor") {
            if let range = systemColor.range(of: "Color") {
                systemColor.removeSubrange(range)
            }
            value = "UIColor.\(systemColor)"
        }
        else {
            throw XIBParser.Error.unknown(attributes: attributes)
        }
        try document.addVariableConfiguration(for: parent.identifier, attribute: key, value: BasicValue(value: value))
        return parent
    }
}
