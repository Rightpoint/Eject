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

    var document: IBDocument? { return reference.document }
    var identifier: String { return reference.identifier }
    var generators: [ObjectCodeGenerator] {
        get {
            return reference.generators
        }
        set(newGenerator) {
            reference.generators = newGenerator
        }
    }

    func configurationGenerator(for key: String, rvalue: CodeGenerator) -> ObjectCodeGenerator {
        guard key == "value" else { fatalError("Expecting key 'value'.") }
        return VariableConfiguration(objectIdentifier: identifier, key: keyPath, value: rvalue, setterContext: nil)
    }

}

struct UserDefinedAttributeBuilder: Builder {

    func configure(parent: IBGraphable?, attributes: [String: String]) -> IBGraphable {
        guard let object = parent as? IBReference else { fatalError("No parent to configure") }
        guard let keyPath = attributes["keyPath"] else { fatalError("No keypath") }
        return IBUserDefinedProxy(reference: object, keyPath: keyPath)
    }

}
