//
//  XIBParser.swift
//  Eject
//
//  Created by Brian King on 10/17/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

protocol Builder {
    func configure(parent: IBReference?, document: IBDocument, attributes: [String: String]) -> IBReference?
}

protocol CharacterBuilder {
    func found(characters: String)
}

protocol ContainerBuilder {
    func add(object: IBReference, to parent: IBReference)
}

protocol BuilderLookup {
    func lookupBuilder(for elementName: String) -> Builder?
}

struct NoOpBuilder: Builder {
    func configure(parent: IBReference?, document: IBDocument, attributes: [String: String]) -> IBReference? { return parent }
}

class XIBParser: NSObject {
    private let parser: XMLParser
    private let documentBuilder = DocumentBuilder()

    var builderStack: [Builder] = []
    var stack: [IBReference?] = []

    var document: IBDocument {
        return documentBuilder.document
    }

    init(data: Data) throws {
        self.parser = XMLParser(data: data)
        super.init()
        self.parser.delegate = self
        try parser.throwingParse()
    }

    var lastObject: IBReference? {
        return stack.last ?? nil
    }

    var lastBuilder: Builder? {
        return builderStack.last
    }

    var builderLookup: BuilderLookup {
        return documentBuilder
    }

}

extension XIBParser: XMLParserDelegate {
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        guard let builder = builderLookup.lookupBuilder(for: elementName) else {
            print("No builder found for \(elementName)")
            return
        }
        builderStack.append(builder)
        let nextObject = builder.configure(parent: lastObject, document: document, attributes: attributeDict)
        stack.append(nextObject)
    }

    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard builderLookup.lookupBuilder(for: elementName) != nil else {
            return
        }
        let object = stack.removeLast()
        builderStack.removeLast()
        if let lastBuilder = lastBuilder as? ContainerBuilder, let object = object {
            lastBuilder.add(object: object, to: lastObject!)
        }
    }

    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        if let characterBuilder = lastBuilder as? CharacterBuilder {
            characterBuilder.found(characters: string)
        }
    }

}
