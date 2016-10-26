//
//  RectBuilder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct RectBuilder: Builder {

    func buildElement(attributes: [String: String], document: XIBDocument, parent: Reference?) -> Reference? {
        guard let parent = parent else { fatalError("No parent to configure") }
        guard
            let key = attributes["key"],
            let x = attributes["x"]?.floatValue?.shortString,
            let y = attributes["y"]?.floatValue?.shortString,
            let width = attributes["width"]?.floatValue?.shortString,
            let height = attributes["height"]?.floatValue?.shortString
            else {
                fatalError("Invalid Rect")
        }
        document.addVariableConfiguration(for: parent.identifier, key: key, value: BasicValue(value: "CGRect(x: \(x), y: \(y), width: \(width), height: \(height))"))
        return parent
    }

}

struct SizeBuilder: Builder {

    func buildElement(attributes: [String: String], document: XIBDocument, parent: Reference?) -> Reference? {
        guard let parent = parent else { fatalError("No parent to configure") }
        guard
            let key = attributes["key"],
            let width = attributes["width"]?.floatValue?.shortString,
            let height = attributes["height"]?.floatValue?.shortString
            else {
                fatalError("Invalid Size")
        }
        document.addVariableConfiguration(for: parent.identifier, key: key, value: BasicValue(value: "CGSize(width: \(width), height: \(height))"))
        return parent
    }

}

struct InsetBuilder: Builder {

    // <inset key="x" minX="0.0" minY="0.0" maxX="0.0" maxY="0.0"/>
    func buildElement(attributes: [String: String], document: XIBDocument, parent: Reference?) -> Reference? {
        guard let parent = parent else { fatalError("No parent to configure") }
        guard
            let key = attributes["key"],
            let x = attributes["minX"]?.floatValue,
            let y = attributes["minY"]?.floatValue,
            let width = attributes["maxX"]?.floatValue,
            let height = attributes["maxY"]?.floatValue
            else {
                fatalError("Invalid inset")
        }
        document.addVariableConfiguration(for: parent.identifier, key: key, value: BasicValue(value: "UIEdgeInsets(top: \(y.shortString), left: \(x.shortString), bottom: \((y + height).shortString), right: \((x + width).shortString))"))
        return parent
    }

}

struct BasicBuilder: Builder {
    let key: String
    let format: ValueFormat

    func buildElement(attributes: [String: String], document: XIBDocument, parent: Reference?) -> Reference? {
        guard let parent = parent else { fatalError("No parent to configure") }
        guard let value = attributes[key] else {
            fatalError("Invalid Rect")
        }
        document.addVariableConfiguration(for: parent.identifier, key: key, value: BasicValue(value: value, format: format))
        return parent
    }
    
}

