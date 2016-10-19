//
//  ValueGenerators.swift
//  Eject
//
//  Created by Brian King on 10/17/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation


/// This value representable encapsulates enumerations.
struct EnumValue: CodeGenerator {
    var value: String

    func generateCode(in context: GenerationContext) -> String? {
        return ".\(value)"
    }
}

struct OptionSetValue: CodeGenerator {
    var keys: [String]

    init(attributes: [String: String]) {
        let keys = attributes.map() { $0.value == "YES" ? .some($0.key) : nil }.flatMap() { $0 }
        self.keys = keys
    }

    func generateCode(in context: GenerationContext) -> String? {
        return "[\(keys.map() { ".\($0)" }.joined(separator: ", "))]"
    }
}

struct BoolValue: CodeGenerator {
    var value: String

    func generateCode(in context: GenerationContext) -> String? {
        return value == "YES" ? "true" : "false"
    }
}

struct StringValue: CodeGenerator {
    var value: String

    func generateCode(in context: GenerationContext) -> String? {
        return value
    }
}

struct NilValue: CodeGenerator {
    func generateCode(in context: GenerationContext) -> String? {
        return "nil"
    }
}

struct VariableValue: CodeGenerator {
    var object: IBObject
    func generateCode(in context: GenerationContext) -> String? {
        let document = context.document
        return document.variable(for: object)
    }
}

struct RectValue: CodeGenerator {
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat

    func generateCode(in context: GenerationContext) -> String? {
        return "CGRect(x: \(x), y:\(y), width: \(width), height: \(height))"
    }
}

struct ConstructorValue: CodeGenerator {
    var className: String
    func generateCode(in context: GenerationContext) -> String? {
        return "\(className)()"
    }
}
