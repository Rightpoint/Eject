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

    func buildElement(attributes: inout [String: String], document: XIBDocument, parent: Reference?) throws -> Reference? {
        guard let parent = parent else { throw XIBParser.Error.needParent }
        let property = try attributes.removeRequiredValue(forKey: "property")
        let destination = try attributes.removeRequiredValue(forKey: "destination")
        attributes.removeValue(forKey: "id")
        attributes.removeValue(forKey: "appends")
        let value = VariableValue(objectIdentifier: destination)
        try document.addVariableConfiguration(
            for: parent.identifier,
            key: property,
            value: value,
            context: setterStyle
        )
        // Specify the outlet name as a variable name override. This rule is ignored for `view` because it's in most view controller .xib's, 
        // and the class-inferred name is almost always better than 'view'. Also, if the outlet is to a collection, do not use it, it will look
        // wrong and probably have a duplication.
        if document.variableNameOverrides[destination] == nil && property != "view" && collection == false {
            document.variableNameOverrides[destination] = { _ in property }
        }
        return parent
    }

}
