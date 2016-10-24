//
//  Declaration.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct Declaration: ObjectCodeGenerator {
    let objectIdentifier: String
    let className: String
    let arguments: [String: String]

    func generationPhase(in document: IBDocument) -> ObjectGenerationPhase {
        let object = document.lookupReference(for: objectIdentifier)
        let scope = document.scope(for: object)
        switch scope {
        case .local:
            return .scopeVariable
        case .property:
            return .properties
        }
    }

    func generateCode(in document: IBDocument) -> String {
        let object = document.lookupReference(for: objectIdentifier)
        let variable = document.variable(for: object)
        let argumentString = arguments.map() { "\($0): \($1)" }.joined(separator: ", ")
        return "let \(variable) = \(className)(\(argumentString))"
    }
}
