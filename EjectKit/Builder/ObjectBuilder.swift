//
//  ObjectBuilder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct ObjectBuilder: Builder {
    struct Property {
        let key: String
        let format: ValueFormat
        let defaultValue: String
        let injected: Bool
        static func p(_ key: String, _ format: ValueFormat, defaultValue: String = "", injected: Bool = false) -> Property {
            return Property(key: key, format: format, defaultValue: defaultValue, injected: injected)
        }
    }
    var className: String
    var properties: [Property]
    var placeholder: Bool

    init(className: String, properties: [Property] = [], placeholder: Bool = false) {
        self.className = className
        self.properties = properties
        self.placeholder = placeholder
    }

    func buildElement(attributes: inout [String: String], document: XIBDocument, parent: Reference?) throws -> Reference? {
        // if a key is specified, the ID can be nil, so just generate a UUID in that case.
        let identifier = attributes.removeValue(forKey: "id") ?? UUID().uuidString
        let className = attributes.removeValue(forKey: "customClass") ?? self.className

        let declaration: XIBDocument.Declaration
        if placeholder {
            declaration = .placeholder
            for key in ["customModule", "placeholderIdentifier", "customModuleProvider"] {
                attributes.removeValue(forKey: key)
            }
        }
        else {
            declaration = .initializer(properties.filter() { $0.injected }.map() { $0.key }, .initialization)
        }
        let object = document.addObject(
            for: identifier,
            className: className,
            userLabel: attributes.removeValue(forKey: "userLabel"),
            declaration: declaration
        )

        // If a key is specified, add a configuration to the parent
        if let parentKey = attributes.removeValue(forKey: "key") {
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

        for property in properties {
            if let value = attributes.removeValue(forKey: property.key) {
                if property.injected {
                    document.lookupReference(for: identifier).values[property.key] = BasicValue(value: value, format: property.format)
                }
                else if value != property.defaultValue {
                    document.addVariableConfiguration(
                        for: object.identifier,
                        key: property.key,
                        value: BasicValue(value: value, format: property.format)
                    )
                }
            }
        }
        return object
    }

    func inherit(className: String, properties: [Property] = []) -> ObjectBuilder {
        var subclass = self
        subclass.className = className
        subclass.properties.append(contentsOf: properties)
        return subclass
    }
    
}
