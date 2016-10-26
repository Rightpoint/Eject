//
//  OutletBuilder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct OutletBuilder: Builder {
    let collection: Bool

    var setterStyle: ConfigurationContext {
        return collection ? .append : .assignment
    }

    func buildElement(attributes: [String: String], document: XIBDocument, parent: Reference?) throws -> Reference? {
        guard let parent = parent else { throw XIBParser.Error.needParent }
        guard let property = attributes["property"] else { throw XIBParser.Error.requiredAttribute(attribute: "property") }
        guard let destination = attributes["destination"] else { throw XIBParser.Error.requiredAttribute(attribute: "destination") }

        let value = VariableValue(objectIdentifier: destination)
        document.addVariableConfiguration(
            for: parent.identifier,
            key: property,
            value: value,
            context: setterStyle
        )
        return parent
    }

}
