//
//  ObjectBuilder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct ObjectBuilder: Builder {
    var className: String
    var properties: [(String, ValueFormat)]
    var generators: [([String: String]) -> ObjectCodeGenerator?]

    init(className: String, properties: [(String, ValueFormat)] = [], generators: [([String: String]) -> ObjectCodeGenerator?] = []) {
        self.className = className
        self.properties = properties
        self.generators = generators
    }

    func configure(parent: IBReference?, document: IBDocument, attributes: [String: String]) -> IBReference? {
        guard let identifier = attributes["id"] else { fatalError("Must have identifier") }
        let className = attributes["customClass"] ?? self.className
        let object = document.addObject(for: identifier,
                                        className: className,
                                        userLabel: attributes["userLabel"],
                                        parent: parent as? IBObject)

        // Build the arguments to inject into the constructor.
        let arguments: [String: String] = properties.reduce([:]) { arguments, tuple in
            var arguments = arguments
            switch (attributes[tuple.0], tuple.1) {
            case let (value?, .inject(string)):
                arguments[tuple.0] = string.transform(string: value)
            case let (_, .injectDefault(value)):
                arguments[tuple.0] = value
            default:
                break
            }
            return arguments
        }

        // Add a generator for the declaration of this object
        object.addDeclaration(arguments: arguments)

        // If a key is specified, add a configuration to the parent
        if let parentKey = attributes["key"] {
            guard let parent = parent as? IBObject else {
                fatalError("Must have a parent if the object defines a parent key")
            }
            parent.addVariableConfiguration(for: parentKey, value: VariableValue(objectIdentifier: object.identifier))
        }

        for (key, format) in properties {
            switch (format, attributes[key]) {
            case (.inject, _):
                fallthrough
            case (.injectDefault, _):
                break // ignore properties that are injected into the constructor
            case let (_, value?):
                object.addVariableConfiguration(for: key, value: BasicValue(value: value, format: format))
            default:
                break
            }
        }

        for block in generators {
            if let config = block(attributes) {
                object.generators.append(config)
            }
        }
        return object
    }

    func inherit(className: String, properties: [(String, ValueFormat)] = [], generators: [([String: String]) -> ObjectCodeGenerator?] = []) -> ObjectBuilder {
        var subclass = self
        subclass.className = className
        subclass.properties.append(contentsOf: properties)
        subclass.generators.append(contentsOf: generators)
        return subclass
    }
    
}
