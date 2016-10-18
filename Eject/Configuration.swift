//
//  Properties.swift
//  Eject
//
//  Created by Brian King on 10/17/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct SubviewConfiguration: CodeGeneration {
    var objectIdentifier: String
    var subviews: [IBObject]

    var dependent: [IBObject] { return subviews }

    func generateCode(in context: CodeGenerationContext) -> String? {
        let document = context.document
        let object = document.object(for: objectIdentifier)
        let variable = document.variable(for: object)
        var representation = ""
        for subview in subviews {
            let subviewVariable = document.variable(for: subview)
            representation.append("\(variable).addSubview(\(subviewVariable))\n")
        }
        return representation
    }
}

struct VariableConfiguration: CodeGeneration {
    var objectIdentifier: String
    var key: String = ""
    var value: CodeGeneration
    // This bit of information adds support for `forState: .touchUpInside`
    var setterContext: String? = nil

    func generateCode(in context: CodeGenerationContext) -> String? {
        let document = context.document
        let object = document.object(for: objectIdentifier)
        let variable = document.variable(for: object)
        if let setterContext = setterContext {
            return "\(variable).set\(key.capitalized)(\(value.generateCode(in: context)), \(setterContext))"
        }
        else {
            return "\(variable).\(key) = \(value.generateCode(in: context))"
        }
    }
}

extension IBObject {
    func addVariableConfiguration(forKey key: String, value: ValueRepresentable, setterContext: String? = nil) {
        generators.append(VariableConfiguration(objectIdentifier: identifier, key: key, value: value, setterContext: setterContext))
    }
}
