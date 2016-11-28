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

    func generateCode(in document: XIBDocument) throws -> String? {
        guard !document.isPlaceholder(for: objectIdentifier) else {
            return nil
        }
        let object = try document.lookupReference(for: objectIdentifier)
        let variable = document.variable(for: object)


        let injectedProperties = object.definition.properties.filter() { $0.injected }.map() { $0.key.propertyName }
        let arguments = try injectedProperties.map() { (property: String) -> String? in
            if let generator = object.values[property], let value = try generator.generateCode(in: document) {
                return "\(property): \(value)"
            }
            return nil
        }.flatMap() { $0 }

        return "let \(variable) = \(className)(\(arguments.joined(separator: ", ")))"
    }
}
