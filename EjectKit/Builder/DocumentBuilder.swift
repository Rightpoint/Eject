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
        func buildElement(attributes: inout [String: String], document: XIBDocument, parent: Reference?) throws -> Reference? {
            let identifier = try attributes.removeRequiredValue(forKey: "identifier")
            if identifier == "com.apple.InterfaceBuilder.IBCocoaTouchPlugin" {
                documentBuilder!.registerPrimitives()
                documentBuilder!.registerCocoaTouch()
            }

            document.documentInformation["version"] = attributes.removeValue(forKey: "version")
            return nil
        }
    }

    struct NoOpBuilder: Builder {
        func buildElement(attributes: inout [String: String], document: XIBDocument, parent: Reference?) -> Reference? {
            attributes.removeAll()
            return parent
        }
    }

}


