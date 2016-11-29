//
//  RectBuilder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct RectBuilder: Builder {

    func buildElement(attributes: inout [String: String], document: XIBDocument, parent: Reference?) throws -> Reference? {
        guard let parent = parent else { throw XIBParser.Error.needParent }
        let key = try attributes.removeRequiredValue(forKey: "key")
        let x = try attributes.removeFloatString(forKey: "x") ?? "0"
        let y = try attributes.removeFloatString(forKey: "y") ?? "0"
        let width = try attributes.removeFloatString(forKey: "width") ?? "0"
        let height = try attributes.removeFloatString(forKey: "height") ?? "0"

        if key == "frame" && document.configuration.useFrames == false {
            return parent
        }
        try document.addVariableConfiguration(
            for: parent.identifier,
            attribute: key,
            value: BasicValue(value: "CGRect(x: \(x), y: \(y), width: \(width), height: \(height))")
        )
        return parent
    }

}

struct SizeBuilder: Builder {

    func buildElement(attributes: inout [String: String], document: XIBDocument, parent: Reference?) throws -> Reference? {
        guard let parent = parent else { throw XIBParser.Error.needParent }
        let key = try attributes.removeRequiredValue(forKey: "key")
        let width = try attributes.removeFloatString(forKey: "width") ?? "0"
        let height = try attributes.removeFloatString(forKey: "height") ?? "0"

        try document.addVariableConfiguration(
            for: parent.identifier,
            attribute: key,
            value: BasicValue(value: "CGSize(width: \(width), height: \(height))")
        )
        return parent
    }

}

struct InsetBuilder: Builder {

    func buildElement(attributes: inout [String: String], document: XIBDocument, parent: Reference?) throws -> Reference? {
        guard let parent = parent else { throw XIBParser.Error.needParent }
        let key = try attributes.removeRequiredValue(forKey: "key")
        let x = try attributes.removeFloat(forKey: "minX")
        let y = try attributes.removeFloat(forKey: "minY")
        let width = try attributes.removeFloat(forKey: "maxX")
        let height = try attributes.removeFloat(forKey: "maxY")

        let edgeInsets = "UIEdgeInsets(top: \(y.shortString), left: \(x.shortString), bottom: \((y + height).shortString), right: \((x + width).shortString))"
        try document.addVariableConfiguration(
            for: parent.identifier,
            attribute: key,
            value: BasicValue(value: edgeInsets))
        return parent
    }

}

struct EdgeInsetBuilder: Builder {

    func buildElement(attributes: inout [String: String], document: XIBDocument, parent: Reference?) throws -> Reference? {
        guard let parent = parent else { throw XIBParser.Error.needParent }
        let key = try attributes.removeRequiredValue(forKey: "key")
        let top = try attributes.removeFloat(forKey: "top")
        let left = try attributes.removeFloat(forKey: "left")
        let bottom = try attributes.removeFloat(forKey: "bottom")
        let right = try attributes.removeFloat(forKey: "right")

        let edgeInsets = "UIEdgeInsets(top: \(top.shortString), left: \(left.shortString), bottom: \(bottom.shortString), right: \(right.shortString))"
        try document.addVariableConfiguration(
            for: parent.identifier,
            attribute: key,
            value: BasicValue(value: edgeInsets))
        return parent
    }
    
}

struct BasicBuilder: Builder {
    let key: String
    let format: ValueFormat

    func buildElement(attributes: inout [String: String], document: XIBDocument, parent: Reference?) throws -> Reference? {
        guard let parent = parent else { throw XIBParser.Error.needParent }
        let value = try attributes.removeRequiredValue(forKey: key)

        try document.addVariableConfiguration(
            for: parent.identifier,
            attribute: key,
            value: BasicValue(value: value, format: format)
        )
        return parent
    }
    
}
