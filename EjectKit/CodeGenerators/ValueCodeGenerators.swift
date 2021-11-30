//
//  ValueCodeGenerators.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct OptionSetValue: CodeGenerator {
    let keys: [String]

    init(attributes: [String: String]) {
        let keys = attributes.map() { $0.value == "YES" ? .some($0.key) : nil }.compactMap() { $0 }
        self.keys = keys
    }

    func generateCode(in document: XIBDocument) throws -> String? {
        return "[\(keys.map() { ".\($0)" }.joined(separator: ", "))]"
    }
}

struct VariableValue: CodeGenerator {
    let objectIdentifier: String

    var dependentIdentifiers: Set<String> {
        return [objectIdentifier]
    }

    func generateCode(in document: XIBDocument) throws -> String? {
        let object = try document.lookupReference(for: objectIdentifier)
        return document.variable(for: object)
    }
}

// This is a class, because some builders will use this as mutable state after it's been added to the hierarchy.
class BasicValue: CodeGenerator {
    let format: ValueFormat
    var value: String = ""

    init(value: String, format: ValueFormat = .raw) {
        self.value = value
        self.format = format
    }

    func generateCode(in document: XIBDocument) throws -> String? {
        return format.transform(string: value)
    }
}
