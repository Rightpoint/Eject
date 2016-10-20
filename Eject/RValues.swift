//
//  SharedValueGenerators.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

indirect enum RValueFormat {
    case raw
    case number
    case enumeration
    case boolean
    case string
    case image

    // These two cases are overloading the use of this enumeration, but it's easy and I'm sorry.
    case inject(RValueFormat)
    // This is to just inject a string value, no matter what's in the attributes.
    // This is disapointingly needed for UITableView, passing in style and frame, but frame isn't available yet, so pass in .zero and re-configure.
    case injectDefault(String)

    func transform(string value: String) -> String {
        switch self {
        case .raw:
            return value
        case .number:
            return value
        case .enumeration:
            return ".\(value)"
        case .boolean:
            return value == "YES" ? "true" : "false"
        case .string:
            return "\"\(value)\""
        case .image:
            return "UIImage(named: \"\(value)\")"
        case let .inject(format):
            return format.transform(string: value)
        case .injectDefault:
            fatalError("Should not attempt to transform a default injection.")
        }
    }
}


// Note, this is a class, because some builders will use this as mutable state after it's been added to the hierarchy.
class BasicRValue: CodeGenerator {
    let format: RValueFormat
    var value: String = ""

    init(value: String, format: RValueFormat = .raw) {
        self.value = value
        self.format = format
    }

    func generateCode(in context: GenerationContext) -> String? {
        return format.transform(string: value)
    }
}

struct OptionSetRValue: CodeGenerator {
    let keys: [String]

    init(attributes: [String: String]) {
        let keys = attributes.map() { $0.value == "YES" ? .some($0.key) : nil }.flatMap() { $0 }
        self.keys = keys
    }

    func generateCode(in context: GenerationContext) -> String? {
        return "[\(keys.map() { ".\($0)" }.joined(separator: ", "))]"
    }
}

struct VariableRValue: CodeGenerator {
    let objectIdentifier: String

    func generateCode(in context: GenerationContext) -> String? {
        let document = context.document
        let object = document.lookupReference(for: objectIdentifier)
        return document.variable(for: object)
    }
}
