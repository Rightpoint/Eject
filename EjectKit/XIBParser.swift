//
//  XIBParser.swift
//  Eject
//
//  Created by Brian King on 10/17/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

protocol Builder {
    func buildElement(attributes: [String: String], document: IBDocument, parent: IBReference?) -> IBReference?
    func complete(document: IBDocument)
}

extension Builder {
    func complete(document: IBDocument) {}
}

protocol CharacterBuilder {
    func found(characters: String)
}

protocol ContainerBuilder {
    func didAddChild(object: IBReference, to parent: IBReference, document: IBDocument)
}

protocol BuilderLookup {
    func lookupBuilder(for elementName: String) -> Builder?
}

struct NoOpBuilder: Builder {
    func buildElement(attributes: [String: String], document: IBDocument, parent: IBReference?) -> IBReference? { return parent }
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
        let nextObject = builder.buildElement(attributes: attributeDict, document: document, parent: lastObject)
        stack.append(nextObject)
    }

    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard builderLookup.lookupBuilder(for: elementName) != nil else {
            return
        }
        let object = stack.removeLast()
        let completedBuilder = builderStack.removeLast()
        completedBuilder.complete(document: document)
        if let lastBuilder = lastBuilder as? ContainerBuilder, let object = object {
            lastBuilder.didAddChild(object: object, to: lastObject!, document: document)
        }
    }

    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard let characterBuilder = lastBuilder as? CharacterBuilder else {
            return
        }
        characterBuilder.found(characters: string)
    }

}
