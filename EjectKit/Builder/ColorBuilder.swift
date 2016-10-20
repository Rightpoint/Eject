//
//  ColorBuilder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct ColorBuilder: Builder {

    func configure(parent: IBReference?, document: IBDocument, attributes: [String: String]) -> IBReference? {
        guard let parent = parent else { fatalError("No parent to configure") }
        guard let key = attributes["key"] else { fatalError("Must specify key") }
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
        else {
            fatalError("Unknown color \(attributes)")
        }
        parent.addVariableConfiguration(for: key, rvalue: BasicRValue(value: value))
        return parent
    }
}
