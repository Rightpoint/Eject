//
//  ButtonStateBuilder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct ButtonStateBuilder: Builder {

    func buildElement(attributes: [String: String], document: IBDocument, parent: IBReference?) -> IBReference? {
        guard let parent = parent else { fatalError("No parent to configure") }
        guard let state = attributes["key"] else { fatalError("No state attribute") }
        document.containerContext = .setter(suffix: "for: \(ValueFormat.enumeration.transform(string: state))")

        let attributeFormat: [(String, ValueFormat)] = [("title", .string), ("image", .image)]
        for (key, format) in attributeFormat {
            if let value = attributes[key] {
                document.addVariableConfiguration(for: parent.identifier, key: key, value: BasicValue(value: value, format: format))
            }
        }
        return parent
    }

    func complete(document: IBDocument) {
        document.containerContext = nil
    }

}
