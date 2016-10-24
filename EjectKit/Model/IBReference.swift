//
//  IBReference.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

/// An protocol that references something in the object graph that enerates code
public protocol IBReference: class {
    var identifier: String { get }
    var className: String { get }
    var userLabel: String? { get }
    var generators: [ObjectCodeGenerator] { get set }

    func configurationGenerator(for key: String, value: CodeGenerator) -> ObjectCodeGenerator
}

extension IBReference {

    // Default implementation
    public func configurationGenerator(for key: String, value: CodeGenerator) -> ObjectCodeGenerator {
        return VariableConfiguration(objectIdentifier: identifier, key: key, value: value, style: .assignment)
    }

    func addVariableConfiguration(for key: String, value: CodeGenerator) {
        let generator = configurationGenerator(for: key, value: value)
        generators.append(generator)
    }
}
