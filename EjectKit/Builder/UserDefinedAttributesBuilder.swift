//
//  UserDefinedRuntimeAttributesBuilder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

/// This is a proxy object that isn't actually added to the graph. It changes the keyPath
/// used in configuration of contained builders
class IBUserDefinedProxy: IBReference {
    let reference: IBReference
    let keyPath: String
    init(reference: IBReference, keyPath: String) {
        self.reference = reference
        self.keyPath = keyPath
    }

    var identifier: String { return reference.identifier }
    var className: String { return reference.className }
    var userLabel: String? { return reference.userLabel }

    var generators: [ObjectCodeGenerator] {
        get {
            return reference.generators
        }
        set(newGenerator) {
            reference.generators = newGenerator
        }
    }

    func configurationGenerator(for key: String, value: CodeGenerator) -> ObjectCodeGenerator {
        guard key == "value" else { fatalError("Expecting key 'value'.") }
        return VariableConfiguration(objectIdentifier: identifier, key: keyPath, value: value, style: .assignment)
    }

}

struct UserDefinedAttributeBuilder: Builder {

    func configure(parent: IBReference?, document: IBDocument, attributes: [String: String]) -> IBReference? {
        guard let object = parent else { fatalError("No parent to configure") }
        guard let keyPath = attributes["keyPath"] else { fatalError("No keypath") }
        return IBUserDefinedProxy(reference: object, keyPath: keyPath)
    }

}
