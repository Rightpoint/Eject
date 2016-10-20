//
//  OutletBuilder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct OutletBuilder: Builder {

    func configure(parent: IBGraphable?, attributes: [String: String]) -> IBGraphable {
        guard let parent = parent as? IBReference else { fatalError("No parent to configure") }
        guard let property = attributes["property"] else { fatalError("Must specify key") }
        guard let destination = attributes["destination"] else { fatalError("Must specify destination") }

        parent.addVariableConfiguration(for: property, rvalue: VariableRValue(objectIdentifier: destination))
        return parent
    }

}
