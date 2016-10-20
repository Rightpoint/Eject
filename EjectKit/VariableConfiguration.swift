//
//  VariableConfiguration.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct VariableConfiguration: ObjectCodeGenerator {
    var objectIdentifier: String
    var key: String = ""
    var value: CodeGenerator
    // This bit of information adds support for `forState: .normal`
    var setterContext: String? = nil

    func generationPhase(in context: GenerationContext) -> ObjectGenerationPhase {
        return .configuration
    }

    func generateCode(in context: GenerationContext) -> String? {
        let document = context.document
        let object = document.lookupReference(for: objectIdentifier)
        let variable = document.variable(for: object)
        if let setterContext = setterContext {
            return "\(variable).set\(key.capitalized)(\(value.generateCode(in: context) ?? "<ERROR>"), \(setterContext))"
        }
        else {
            return "\(variable).\(key) = \(value.generateCode(in: context) ?? "<ERROR>")"
        }
    }
}
