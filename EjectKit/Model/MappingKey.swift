//
//  MappingKey.swift
//  Eject
//
//  Created by Brian King on 11/12/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation


// A mapping between an XML attribute and the object property.
enum MappingKey: ExpressibleByStringLiteral {

    init(stringLiteral value: String) {
        self = .key(value)
    }
    init(extendedGraphemeClusterLiteral value: String){
        self.init(stringLiteral: value)
    }
    init(unicodeScalarLiteral value: String) {
        self.init(stringLiteral: value)
    }

    case key(String)
    case map(String, String)
    case addIsPrefix(String)

    var attribute: String {
        switch self {
        case let .key(attribute):
            return attribute
        case let .map(attribute, _):
            return attribute
        case let .addIsPrefix(attribute):
            return attribute
        }
    }

    var propertyName: String {
        switch self {
        case let .key(property):
            return property
        case let .map(_, property):
            return property
        case let .addIsPrefix(property):
            return "is \(property)".snakeCased()
        }
    }
}
