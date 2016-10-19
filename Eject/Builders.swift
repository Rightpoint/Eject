//
//  Builders.swift
//  Eject
//
//  Created by Brian King on 10/17/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

func CocoaTouchBuilder() -> DocumentBuilder {
    let definition = DocumentBuilder()
    definition.register(element: "rect", builder: RectBuilder())
    definition.register(element: "nil", builder: NilBuilder())
    definition.register(element: "dataDetectorType", builder: OptionSetBuilder())

    definition.register(
        element: "view",
        builder: ObjectBuilder(
            className: "UIView",
            boolProperties: ["clearsContextBeforeDrawing", "hidden", "opaque", "clipsToBounds", "translatesAutoresizingMaskIntoConstraints"],
            enumProperties: ["contentMode"],
            stringProperties: [],
            generators: []
        )
    )
    definition.register(
        element: "label",
        builder: ObjectBuilder(
            className: "UILabel",
            boolProperties: ["adjustsFontSizeToFit"],
            enumProperties: ["lineBreakMode"],
            stringProperties: ["text"],
            generators: []
        )
    )
    definition.register(
        element: "webView",
        builder: ObjectBuilder(
            className: "UIWebView",
            boolProperties: [],
            enumProperties: [],
            stringProperties: [],
            generators: []
        )
    )
    return definition
}

class DocumentBuilder: Buildable, BuildableLookup {
    var document = IBDocument()
    var elementBuilders: [String: Buildable] = [:]

    func register(element: String, builder: Buildable) {
        elementBuilders[element] = builder
    }

    func lookupBuilder(for elementName: String) -> Buildable? {
        let builder = elementBuilders[elementName]
        if builder == nil && document.references.count == 0 {
            return self
        }
        return builder
    }

    func configure(parent: IBGraphable?, attributes: [String: String]) -> IBGraphable {
        return document
    }

}

/// This is a simple object provider with some KVC friends.
struct ObjectBuilder {
    var className: String
    var boolProperties: [String]
    var enumProperties: [String]
    var stringProperties: [String]
    var generators: [([String: String]) -> ObjectCodeGenerator?]
}

extension ObjectBuilder: Buildable {

    func configure(parent: IBGraphable?, attributes: [String: String]) -> IBGraphable {
        guard let parent = parent, let document = parent.document else { fatalError("ObjectBuilder must have a parent") }
        guard let identifier = attributes["id"] else { fatalError("Must have identifier") }
        let className = attributes["customClass"] ?? self.className
        let object = document.addObject(for: identifier,
                                        className: className,
                                        userLabel: attributes["userLabel"])
        object.addDeclaration()
        for key in boolProperties {
            if let value = attributes[key] {
                object.addVariableConfiguration(forKey: key, valueGenerator: BoolValue(value: value))
            }
        }
        for key in enumProperties {
            if let value = attributes[key] {
                object.addVariableConfiguration(forKey: key, valueGenerator: EnumValue(value: value))
            }
        }
        for key in stringProperties {
            if let value = attributes[key] {
                object.addVariableConfiguration(forKey: key, valueGenerator: StringValue(value: value))
            }
        }
        for block in generators {
            if let config = block(attributes) {
                object.generators.append(config)
            }
        }
        return object
    }

}

struct RectBuilder: Buildable {
    func configure(parent: IBGraphable?, attributes: [String: String]) -> IBGraphable {
        guard let object = parent as? IBReference else { fatalError("No parent to configure") }
        guard
            let key = attributes["key"],
            let x = attributes["x"]?.float,
            let y = attributes["y"]?.float,
            let width = attributes["width"]?.float,
            let height = attributes["height"]?.float
        else {
            fatalError("Invalid Rect")
        }
        object.addVariableConfiguration(forKey: key, valueGenerator: RectValue(x: x, y: y, width: width, height: height))
        return object
    }

}

struct NilBuilder: Buildable {

    func configure(parent: IBGraphable?, attributes: [String: String]) -> IBGraphable {
        guard let object = parent as? IBReference else { fatalError("No parent to configure") }
        guard let key = attributes["key"] else {
            fatalError("Invalid Nil")
        }
        object.addVariableConfiguration(forKey: key, valueGenerator: NilValue())
        return object
    }
    
}

struct OptionSetBuilder: Buildable {

    func configure(parent: IBGraphable?, attributes: [String: String]) -> IBGraphable {
        guard let object = parent as? IBReference else { fatalError("No parent to configure") }
        var attributes = attributes
        guard let key = attributes.removeValue(forKey: "key") else {
            fatalError("Invalid Nil")
        }
        object.addVariableConfiguration(forKey: key, valueGenerator: OptionSetValue(attributes: attributes))
        return object
    }

}

extension String {

    var float: CGFloat? {
        if let double = Double(self) {
            return CGFloat(double)
        }
        else {
            return nil
        }
    }

}
