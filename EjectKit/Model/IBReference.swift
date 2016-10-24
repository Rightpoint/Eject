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

    func addVariableConfiguration(for key: String, value: CodeGenerator)
}

extension IBReference {
    public func addVariableConfiguration(for key: String, value: CodeGenerator) {
        generators.append(VariableConfiguration(objectIdentifier: identifier, key: key, value: value, style: .assignment))
    }
}
