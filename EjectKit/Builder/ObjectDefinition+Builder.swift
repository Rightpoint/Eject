//
//  ObjectDefinition+Builder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

extension ObjectDefinition: Builder {

    func buildElement(attributes: inout [String: String], document: XIBDocument, parent: Reference?) throws -> Reference? {
        // if a key is specified, the ID can be nil, so just generate a UUID in that case.
        let identifier = attributes.removeValue(forKey: "id") ?? UUID().uuidString
        let customClass = attributes.removeValue(forKey: "customClass")

        // If this is a top level object with a custom class, select this identifier as self.
        if customClass != nil && customClass != "UIResponder" && parent == nil && document.configuration.selfIdentifier == nil {
            document.configuration.selfIdentifier = identifier
        }

        for key in ["customModule", "placeholderIdentifier", "customModuleProvider", "misplaced"] {
            attributes.removeValue(forKey: key)
        }

        let object = document.addObject(
            for: identifier,
            definition: self,
            customSubclass: customClass,
            userLabel: attributes.removeValue(forKey: "userLabel")
        )
        let initializer = Initializer(objectIdentifier: identifier, className: object.className)
        try document.addStatement(for: identifier, generator: initializer, phase: .initialization)

        // If a key is specified, add a configuration to the parent
        if let parentKey = attributes.removeValue(forKey: "key") {
            if document.isPlaceholder(for: identifier) {
                // If this is a placeholder (IE: an object that the parent will initialize internally) set the variable name to the property.
                document.variableNameOverrides[identifier] = { document in
                    if let parent = parent {
                        return [document.variable(for: parent), parentKey].joined(separator: ".")
                    }
                    else {
                        return parentKey
                    }
                }
            }
            else {
                guard let parent = parent else { throw XIBParser.Error.needParent }
                // Otherwise create a create an assignment
                let value = VariableValue(objectIdentifier: object.identifier)
                try document.addVariableConfiguration(for: parent.identifier, attribute: parentKey, value: value)
            }
        }
        try buildElementProperties(attributes: &attributes, document: document, object: object)

        return object
    }

}

struct PropertyBuilder: Builder {
    var keysToRemove: [String]
    var properties: [ObjectDefinition.Property]

    func buildElement(attributes: inout [String: String], document: XIBDocument, parent: Reference?) throws -> Reference? {
        for key in keysToRemove {
            attributes.removeValue(forKey: key)
        }
        return try buildElementProperties(attributes: &attributes, document: document, object: parent)
    }
}

extension PropertyBuilder: PropertyContainer {}
extension ObjectDefinition: PropertyContainer {}

private protocol PropertyContainer: Builder {

    var properties: [ObjectDefinition.Property] { get }

}

extension PropertyContainer {

    @discardableResult func buildElementProperties(attributes: inout [String: String], document: XIBDocument, object: Reference?) throws -> Reference? {
        guard let object = object else { throw XIBParser.Error.needParent }
        let identifier = object.identifier
        for property in properties {
            if let value = attributes.removeValue(forKey: property.key.attribute) {
                if property.injected {
                    // If the property is injected, just add the value
                    try document.lookupReference(for: identifier).values[property.key.propertyName] = BasicValue(value: value, format: property.format)
                }
                else if case .placeholder(let property) = property.context {
                    document.placeholders.append(value)
                    document.variableNameOverrides[value] = { document in
                        return [document.variable(for: object), property].joined(separator: ".")
                    }
                }
                else if value != property.defaultValue && !property.ignored {
                    try document.addVariableConfiguration(
                        for: identifier,
                        attribute: property.key.attribute,
                        value: BasicValue(value: value, format: property.format)
                    )
                }
            }
        }
        return object
    }

}
