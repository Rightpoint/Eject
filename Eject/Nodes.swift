//
//  Hierarchy.swift
//  Eject
//
//  Created by Brian King on 10/17/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

/// This protocol will build the IBObject graph based on the XML properties for the attributes.
protocol IBObjectNode {
    /// Some XML nodes will declare new objects, some will just configure the contained object.
    /// If this node is declaring a new object, return a non-nil value here, with no configurations.
    /// The configurations to be applied to the object will be added later.
    func declaredObject(attributes: [String: String]) -> IBObject?

    /// Almost all XML nodes provide some configuration of the object graph. Return them all here.
    func configuration(for object: IBObject, attributes: [String: String]) -> [CodeRepresentation]
}

/// This is a simple object provider with some KVC friends.
struct ObjectProvidingNode {
    var elementName: String
    var className: String? = nil
    var boolProperties: [String] = []
    var enumProperties: [String] = []
    var stringProperties: [String] = []
    var other: [([String: String]) -> CodeRepresentation?]
}

extension ObjectProvidingNode {
    func declaredObject(attributes: [String: String]) -> IBObject? {
        return IBObject(identifier: attributes["id"]!,
                        className: attributes["customClass"] ?? "UIView",
                        userLabel: attributes["userLabel"],
                        configuration: [])
    }

    func configuration(for object: IBObject, attributes: [String: String]) -> [CodeRepresentation] {
        var configurations: [CodeRepresentation] = []
        for key in boolProperties {
            if let value = attributes[key] {
                let config = object.property(forKey: key, value: BoolValue(value: value))
                configurations.append(config)
            }
        }
        for key in enumProperties {
            if let value = attributes[key] {
                let config = object.property(forKey: key, value: EnumValue(value: value))
                configurations.append(config)
            }
        }
        for key in stringProperties {
            if let value = attributes[key] {
                let config = object.property(forKey: key, value: StringValue(value: value))
                configurations.append(config)
            }
        }
        for block in other {
            if let config = block(attributes) {
                configurations.append(config)
            }
        }
        return configurations
    }

}


let objectNodes = [
    ObjectProvidingNode(elementName: "view",
                        className: "UIView",
                        boolProperties: ["clearsContextBeforeDrawing", "hidden", "opaque", "clipsToBounds", "translatesAutoresizingMaskIntoConstraints"],
                        enumProperties: ["contentMode"],
                        stringProperties: [],
                        other: []),
    ObjectProvidingNode(elementName: "label",
                        className: "UILabel",
                        boolProperties: ["adjustsFontSizeToFit"],
                        enumProperties: ["lineBreakMode"],
                        stringProperties: ["text"],
                        other: []),

]


struct RectNode: IBObjectNode {

    func declaredObject(attributes: [String: String]) -> IBObject? {
        return nil
    }


    func configuration(for object: IBObject, attributes: [String: String]) -> [CodeRepresentation] {
        guard
            let key = attributes["key"],
            let x = attributes["x"]?.float,
            let y = attributes["y"]?.float,
            let width = attributes["width"]?.float,
            let height = attributes["height"]?.float
        else {
            fatalError("Invalid Rect")
        }
        return [Property(objectIdentifier: object.identifier, key: key, value: RectValue(x: x, y: y, width: width, height: height))]
    }

}
