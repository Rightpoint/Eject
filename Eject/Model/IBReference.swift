//
//  IBReference.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

/// An protocol that references something in the object graph that enerates code
protocol IBReference: class {
    var identifier: String { get }
    var className: String { get }
    var userLabel: String? { get }
    var generators: [ObjectCodeGenerator] { get set }

    func configurationGenerator(for key: String, rvalue: CodeGenerator) -> ObjectCodeGenerator
}

extension IBReference {

    // Default implementation
    func configurationGenerator(for key: String, rvalue: CodeGenerator) -> ObjectCodeGenerator {
        return VariableConfiguration(objectIdentifier: identifier, key: key, value: rvalue, setterContext: nil)
    }

    func addVariableConfiguration(for key: String, rvalue: CodeGenerator) {
        let generator = configurationGenerator(for: key, rvalue: rvalue)
        generators.append(generator)
    }
}
