//
//  DocumentBuilder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

class DocumentBuilder: Builder, BuilderLookup {
    var document = IBDocument()
    var elementBuilders: [String: Builder] = [:]

    func register(_ element: String, _ builder: Builder) {
        elementBuilders[element] = builder
    }

    func lookupBuilder(for elementName: String) -> Builder? {
        let builder = elementBuilders[elementName]
        if builder == nil && document.references.count == 0 {
            return self
        }
        return builder
    }

    func configure(parent: IBGraphable?, attributes: [String: String]) -> IBGraphable {
        return document
    }
    
}
