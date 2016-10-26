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
    var placeholder: Bool

    init(className: String, properties: [(String, ValueFormat)] = [], placeholder: Bool = false) {
        self.className = className
        self.properties = properties
        self.placeholder = placeholder
    }

    func buildElement(attributes: [String: String], document: XIBDocument, parent: Reference?) throws -> Reference? {
        let identifier = attributes["id"]
            ?? UUID().uuidString // if a key is specified, the ID can be nil, so just generate a UUID in that case.
        let className = attributes["customClass"] ?? self.className

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
        let declaration: XIBDocument.Declaration
        if placeholder {
            assert(arguments.count == 0)
            declaration = .placeholder
        }
        else {
            declaration = .initializer(arguments, .initialization)
        }
        let object = document.addObject(
            for: identifier,
            className: className,
            userLabel: attributes["userLabel"],
            declaration: declaration
        )

        // If a key is specified, add a configuration to the parent
        if let parentKey = attributes["key"] {
            guard let parent = parent else { throw XIBParser.Error.needParent }
            if case .placeholder = declaration {
                // If this is a placeholder (IE: an object that the parent will initialize internally) set the variable name to the property.
                document.variableNameOverrides[identifier] = parentKey
            }
            else {
                // Otherwise create a create an assignment
                let value = VariableValue(objectIdentifier: object.identifier)
                document.addVariableConfiguration(for: parent.identifier, key: parentKey, value: value)
            }
        }

        for (key, format) in properties {
            switch (format, attributes[key]) {
            case (.inject, _):
                fallthrough
            case (.injectDefault, _):
                break // ignore properties that are injected into the constructor
            case let (_, value?):
                document.addVariableConfiguration(for: object.identifier, key: key, value: BasicValue(value: value, format: format))
            default:
                break
            }
        }
        return object
    }

    func inherit(className: String, properties: [(String, ValueFormat)] = []) -> ObjectBuilder {
        var subclass = self
        subclass.className = className
        subclass.properties.append(contentsOf: properties)
        return subclass
    }
    
}
