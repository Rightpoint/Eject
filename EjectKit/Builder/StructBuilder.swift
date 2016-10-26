//
//  RectBuilder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct RectBuilder: Builder {

    func buildElement(attributes: [String: String], document: XIBDocument, parent: Reference?) throws -> Reference? {
        guard let parent = parent else { throw XIBParser.Error.needParent }
        guard let key = attributes["key"] else { throw XIBParser.Error.requiredAttribute(attribute: "key") }
        guard let x = attributes["x"]?.floatValue?.shortString else { throw XIBParser.Error.requiredAttribute(attribute: "x") }
        guard let y = attributes["y"]?.floatValue?.shortString else { throw XIBParser.Error.requiredAttribute(attribute: "y") }
        guard let width = attributes["width"]?.floatValue?.shortString else { throw XIBParser.Error.requiredAttribute(attribute: "width") }
        guard let height = attributes["height"]?.floatValue?.shortString else { throw XIBParser.Error.requiredAttribute(attribute: "height") }

        document.addVariableConfiguration(for: parent.identifier, key: key, value: BasicValue(value: "CGRect(x: \(x), y: \(y), width: \(width), height: \(height))"))
        return parent
    }

}

struct SizeBuilder: Builder {

    func buildElement(attributes: [String: String], document: XIBDocument, parent: Reference?) throws -> Reference? {
        guard let parent = parent else { throw XIBParser.Error.needParent }
        guard let key = attributes["key"] else { throw XIBParser.Error.requiredAttribute(attribute: "key") }
        guard let width = attributes["width"]?.floatValue?.shortString else { throw XIBParser.Error.requiredAttribute(attribute: "width") }
        guard let height = attributes["height"]?.floatValue?.shortString else { throw XIBParser.Error.requiredAttribute(attribute: "height") }

        document.addVariableConfiguration(for: parent.identifier, key: key, value: BasicValue(value: "CGSize(width: \(width), height: \(height))"))
        return parent
    }

}

struct InsetBuilder: Builder {

    func buildElement(attributes: [String: String], document: XIBDocument, parent: Reference?) throws -> Reference? {
        guard let parent = parent else { throw XIBParser.Error.needParent }
        guard let key = attributes["key"] else { throw XIBParser.Error.requiredAttribute(attribute: "key") }
        guard let x = attributes["minX"]?.floatValue else { throw XIBParser.Error.requiredAttribute(attribute: "minX") }
        guard let y = attributes["minY"]?.floatValue else { throw XIBParser.Error.requiredAttribute(attribute: "minY") }
        guard let width = attributes["maxX"]?.floatValue else { throw XIBParser.Error.requiredAttribute(attribute: "maxX") }
        guard let height = attributes["maxY"]?.floatValue else { throw XIBParser.Error.requiredAttribute(attribute: "maxY") }

        document.addVariableConfiguration(for: parent.identifier, key: key, value: BasicValue(value: "UIEdgeInsets(top: \(y.shortString), left: \(x.shortString), bottom: \((y + height).shortString), right: \((x + width).shortString))"))
        return parent
    }

}

struct BasicBuilder: Builder {
    let key: String
    let format: ValueFormat

    func buildElement(attributes: [String: String], document: XIBDocument, parent: Reference?) throws -> Reference? {
        guard let parent = parent else { throw XIBParser.Error.needParent }
        guard let value = attributes[key] else { throw XIBParser.Error.requiredAttribute(attribute: key) }
        document.addVariableConfiguration(for: parent.identifier, key: key, value: BasicValue(value: value, format: format))
        return parent
    }
    
}

