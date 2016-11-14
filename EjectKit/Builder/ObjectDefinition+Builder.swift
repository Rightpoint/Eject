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

        let declaration: XIBDocument.Declaration
        if placeholder || document.configuration.selfIdentifier == identifier {
            declaration = .placeholder
        }
        else {
            declaration = .initializer(properties.filter() { $0.injected }.map() { $0.key.property }, .initialization)
        }
        let object = document.addObject(
            for: identifier,
            definition: self,
            customSubclass: customClass,
            userLabel: attributes.removeValue(forKey: "userLabel"),
            declaration: declaration
        )

        // If a key is specified, add a configuration to the parent
        if let parentKey = attributes.removeValue(forKey: "key") {
            if case .placeholder = declaration {
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
                try document.addVariableConfiguration(for: parent.identifier, key: parentKey, value: value)
            }
        }
        try buildElementProperties(attributes: &attributes, document: document, object: object)

        return object
    }

    func inherit(className: String, properties: [Property] = [], placeholder: Bool = false) -> ObjectDefinition {
        var subclass = self
        subclass.className = className
        subclass.properties.insert(contentsOf: properties, at: 0)
        subclass.placeholder = placeholder
        return subclass
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

extension PropertyBuilder: ObjectDefinitionPropertyContainer {}
extension ObjectDefinition: ObjectDefinitionPropertyContainer {}

private protocol ObjectDefinitionPropertyContainer: Builder {

    var properties: [ObjectDefinition.Property] { get }

}

extension ObjectDefinitionPropertyContainer {

    @discardableResult func buildElementProperties(attributes: inout [String: String], document: XIBDocument, object: Reference?) throws -> Reference? {
        guard let object = object else { throw XIBParser.Error.needParent }
        let identifier = object.identifier
        for property in properties {
            if let value = attributes.removeValue(forKey: property.key.attribute) {
                if property.injected {
                    // If the property is injected, just add the value
                    try document.lookupReference(for: identifier).values[property.key.property] = BasicValue(value: value, format: property.format)
                }
                else if value != property.defaultValue && !property.ignored {
                    try document.addVariableConfiguration(
                        for: object.identifier,
                        key: property.key.property,
                        value: BasicValue(value: value, format: property.format),
                        context: property.context
                    )
                }
            }
        }
        return object
    }

}
