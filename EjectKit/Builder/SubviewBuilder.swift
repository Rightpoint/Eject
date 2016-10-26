//
//  SubviewBuilder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct SubviewConfiguration: CodeGenerator {
    var objectIdentifier: String
    var subview: IBReference

    var dependentIdentifiers: Set<String> {
        return [objectIdentifier, subview.identifier]
    }

    func generateCode(in document: IBDocument) -> String {
        let object = document.lookupReference(for: objectIdentifier)
        let variable = document.variable(for: object)
        var representation = ""
        let subviewVariable = document.variable(for: subview)
        representation.append("\(variable).addSubview(\(subviewVariable))")
        return representation
    }
}

struct SubviewBuilder: Builder, ContainerBuilder {

    func buildElement(attributes: [String: String], document: IBDocument, parent: IBReference?) -> IBReference? {
        guard let parent = parent else { fatalError("No parent to configure") }
        return parent
    }

    func didAddChild(object: IBReference, to parent: IBReference, document: IBDocument) {
        document.addStatement(
            SubviewConfiguration(objectIdentifier: parent.identifier, subview: object),
            phase: .subviews
        )
    }

}
