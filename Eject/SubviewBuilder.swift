//
//  SubviewBuilder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct SubviewConfiguration: ObjectCodeGenerator {
    var objectIdentifier: String
    var subview: IBObject

    func generationPhase(in context: GenerationContext) -> ObjectGenerationPhase {
        return .subviews
    }

    func generateCode(in context: GenerationContext) -> String? {
        let document = context.document
        let object = document.lookupReference(for: objectIdentifier)
        let variable = document.variable(for: object)
        var representation = ""
        let subviewVariable = document.variable(for: subview)
        representation.append("\(variable).addSubview(\(subviewVariable))")
        return representation
    }
}

struct SubviewBuilder: Builder, ContainerBuilder {

    func configure(parent: IBGraphable?, attributes: [String: String]) -> IBGraphable {
        guard let parent = parent else { fatalError("No parent to configure") }
        return parent
    }

    func add(object: IBGraphable, to parent: IBGraphable) {
        guard let parent = parent as? IBReference else { fatalError("No parent to configure") }
        guard let object = object as? IBObject else { fatalError("Must be an object") }
        parent.generators.append(SubviewConfiguration(objectIdentifier: parent.identifier, subview: object))
    }

}
