//
//  VariableConfiguration.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct VariableConfiguration: ObjectCodeGenerator {
    enum Style {
        case assignment
        case append
        // This adds support for `forState: .normal`
        case setter(context: String)
    }
    let objectIdentifier: String
    let key: String
    let value: CodeGenerator
    let style: Style

    func generationPhase(in context: GenerationContext) -> ObjectGenerationPhase {
        return .configuration
    }

    func generateCode(in context: GenerationContext) -> String? {
        let document = context.document
        let object = document.lookupReference(for: objectIdentifier)
        let variable = document.variable(for: object)

        let valueString = value.generateCode(in: context) ?? "<ERROR>"
        switch style {
        case .assignment:
            return "\(variable).\(key) = \(valueString)"
        case .append:
            return "\(variable).\(key).append(\(valueString))"
        case let .setter(context):
            return "\(variable).set\(key.capitalized)(\(valueString), \(context))"
        }
    }
}
