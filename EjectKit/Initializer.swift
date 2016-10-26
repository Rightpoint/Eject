//
//  Initializer.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct Initializer: CodeGenerator {
    let objectIdentifier: String
    let className: String
    let arguments: [String: String]

    func generateCode(in document: XIBDocument) -> String {
        let object = document.lookupReference(for: objectIdentifier)
        let variable = document.variable(for: object)
        let argumentString = arguments.map() { "\($0): \($1)" }.joined(separator: ", ")
        return "let \(variable) = \(className)(\(argumentString))"
    }
}
