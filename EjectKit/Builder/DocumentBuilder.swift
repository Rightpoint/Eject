//
//  DocumentBuilder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

class DocumentBuilder: BuilderLookup {
    var document = XIBDocument()
    var elementBuilders: [String: Builder] = [:]

    init() {
        register("plugIn", PluginBuilder(documentBuilder: self))
    }

    func register(_ element: String, _ builder: Builder) {
        elementBuilders[element] = builder
    }

    func lookupBuilder(for elementName: String) -> Builder? {
        let builder = elementBuilders[elementName]
        if builder == nil && document.references.count == 0 {
            return NoOpBuilder()
        }
        return builder
    }

    struct PluginBuilder: Builder {
        weak var documentBuilder: DocumentBuilder?
        func buildElement(attributes: [String: String], document: XIBDocument, parent: Reference?) throws -> Reference? {
            guard let identifier = attributes["identifier"] else { throw XIBParser.Error.requiredAttribute(attribute: "identifier") }

            if identifier == "com.apple.InterfaceBuilder.IBCocoaTouchPlugin" {
                documentBuilder!.registerPrimitives()
                documentBuilder!.registerCocoaTouch()
            }
            return nil
        }
    }
}


