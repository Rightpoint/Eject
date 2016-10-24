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

    func configure(parent: IBReference?, document: IBDocument, attributes: [String: String]) -> IBReference? {
        guard let parent = parent else { fatalError("No parent to configure") }
        guard let property = attributes["property"] else { fatalError("Must specify key") }
        guard let destination = attributes["destination"] else { fatalError("Must specify destination") }

        let value = VariableValue(objectIdentifier: destination)
        if collection {
            parent.generators.append(VariableConfiguration(objectIdentifier: parent.identifier, key: property, value: value, style: .append))
        }
        else {
            parent.addVariableConfiguration(for: property, value: value)
        }
        return parent
    }

}
