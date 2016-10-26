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

    func buildElement(attributes: [String: String], document: IBDocument, parent: IBReference?) -> IBReference? {
        guard let parent = parent else { fatalError("No parent to configure") }
        guard let property = attributes["property"] else { fatalError("Must specify key") }
        guard let destination = attributes["destination"] else { fatalError("Must specify destination") }

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
