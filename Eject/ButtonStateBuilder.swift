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

    var document: IBDocument? { return reference.document }
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

    func configurationGenerator(for key: String, rvalue: CodeGenerator) -> ObjectCodeGenerator {
        return VariableConfiguration(objectIdentifier: identifier, key: key, value: rvalue, setterContext: setterContext)
    }
    
}

struct ButtonStateBuilder: Builder {

    func configure(parent: IBGraphable?, attributes: [String: String]) -> IBGraphable {
        guard let object = parent as? IBReference else { fatalError("No parent to configure") }
        guard let state = attributes["key"] else { fatalError("No state attribute") }
        let proxy = IBButtonStateProxy(reference: object, setterContext: "for: \(RValueFormat.enumeration.transform(string: state))")
        let attributeFormat: [(String, RValueFormat)] = [("title", .string), ("image", .image)]
        for (key, format) in attributeFormat {
            if let value = attributes[key] {
                proxy.addVariableConfiguration(for: key, rvalue: BasicRValue(value: value, format: format))
            }
        }
        return proxy
    }

}
