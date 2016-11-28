//
//  ObjectDefinition.swift
//  Eject
//
//  Created by Brian King on 11/12/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct ObjectDefinition {

    struct Property {
        let key: MappingKey
        let format: ValueFormat
        let defaultValue: String
        let context: AssociationContext
        static func build(_ key: MappingKey, _ format: ValueFormat, _ defaultValue: String = "", _ context: AssociationContext = .assignment) -> Property {
            return Property(key: key, format: format, defaultValue: defaultValue, context: context)
        }

        var injected: Bool {
            switch context {
            case .inject:
                return true
            default:
                return false
            }
        }
        var ignored: Bool {
            switch context {
            case .ignore:
                return true
            default:
                return false
            }
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

    func inherit(className: String, properties: [Property] = [], placeholder: Bool = false) -> ObjectDefinition {
        var subclass = self
        subclass.className = className
        subclass.properties.insert(contentsOf: properties, at: 0)
        subclass.placeholder = placeholder
        return subclass
    }

    func property(forAttribute attribute: String) -> Property? {
        for property in properties {
            if property.key.attribute == attribute {
                return property
            }
        }
        return nil
    }
}
