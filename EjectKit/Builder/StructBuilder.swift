//
//  RectBuilder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct RectBuilder: Builder {

    func configure(parent: IBReference?, document: IBDocument, attributes: [String: String]) -> IBReference? {
        guard let object = parent else { fatalError("No parent to configure") }
        guard
            let key = attributes["key"],
            let x = attributes["x"],
            let y = attributes["y"],
            let width = attributes["width"],
            let height = attributes["height"]
            else {
                fatalError("Invalid Rect")
        }
        object.addVariableConfiguration(for: key, value: BasicValue(value: "CGRect(x: \(x), y: \(y), width: \(width), height: \(height))"))
        return object
    }

}

struct SizeBuilder: Builder {

    func configure(parent: IBReference?, document: IBDocument, attributes: [String: String]) -> IBReference? {
        guard let object = parent else { fatalError("No parent to configure") }
        guard
            let key = attributes["key"],
            let width = attributes["width"],
            let height = attributes["height"]
            else {
                fatalError("Invalid Size")
        }
        object.addVariableConfiguration(for: key, value: BasicValue(value: "CGSize(width: \(width), height: \(height))"))
        return object
    }

}

struct InsetBuilder: Builder {

    // <inset key="x" minX="0.0" minY="0.0" maxX="0.0" maxY="0.0"/>
    func configure(parent: IBReference?, document: IBDocument, attributes: [String: String]) -> IBReference? {
        guard let object = parent else { fatalError("No parent to configure") }
        guard
            let key = attributes["key"],
            let x = attributes["minX"]?.floatValue,
            let y = attributes["minY"]?.floatValue,
            let width = attributes["maxX"]?.floatValue,
            let height = attributes["maxY"]?.floatValue
            else {
                fatalError("Invalid inset")
        }
        object.addVariableConfiguration(for: key, value: BasicValue(value: "UIEdgeInsets(top: \(y), left: \(x), bottom: \(y + height), right: \(x + width))"))
        return object
    }

}

struct BasicBuilder: Builder {
    let key: String
    let format: ValueFormat

    func configure(parent: IBReference?, document: IBDocument, attributes: [String: String]) -> IBReference? {
        guard let object = parent else { fatalError("No parent to configure") }
        guard let value = attributes[key] else {
            fatalError("Invalid Rect")
        }
        object.addVariableConfiguration(for: key, value: BasicValue(value: value, format: format))
        return object
    }
    
}

