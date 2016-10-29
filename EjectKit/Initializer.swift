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
    let injectedProperties: [String]

    func generateCode(in document: XIBDocument) -> String {
        let object = document.lookupReference(for: objectIdentifier)
        let variable = document.variable(for: object)
        let arguments = injectedProperties.map() { (property: String) -> String? in
            if let generator = object.values[property] {
                return "\(property): \(generator.generateCode(in: document))"
            }
            return nil
        }.flatMap() { $0 }

        return "let \(variable) = \(className)(\(arguments.joined(separator: ", ")))"
    }
}
