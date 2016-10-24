//
//  ButtonStateBuilder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

class IBButtonStateProxy: IBReference {
    let reference: IBReference
    let setterContext: String
    init(reference: IBReference, setterContext: String) {
        self.reference = reference
        self.setterContext = setterContext
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
        return VariableConfiguration(objectIdentifier: identifier, key: key, value: value, style: .setter(context: setterContext))
    }
    
}

struct ButtonStateBuilder: Builder {

    func configure(parent: IBReference?, document: IBDocument, attributes: [String: String]) -> IBReference? {
        guard let object = parent else { fatalError("No parent to configure") }
        guard let state = attributes["key"] else { fatalError("No state attribute") }
        let proxy = IBButtonStateProxy(reference: object, setterContext: "for: \(ValueFormat.enumeration.transform(string: state))")
        let attributeFormat: [(String, ValueFormat)] = [("title", .string), ("image", .image)]
        for (key, format) in attributeFormat {
            if let value = attributes[key] {
                proxy.addVariableConfiguration(for: key, value: BasicValue(value: value, format: format))
            }
        }
        return proxy
    }

}
