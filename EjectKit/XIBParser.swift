//
//  XIBParser.swift
//  Eject
//
//  Created by Brian King on 10/17/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

protocol Builder {
    func buildElement(attributes: [String: String], document: XIBDocument, parent: Reference?) throws -> Reference?
    func complete(document: XIBDocument)
}

extension Builder {
    func complete(document: XIBDocument) {}
}

protocol CharacterBuilder {
    func found(characters: String)
}

protocol ContainerBuilder {
    func didAddChild(object: Reference, to parent: Reference, document: XIBDocument)
}

protocol BuilderLookup {
    func lookupBuilder(for elementName: String) -> Builder?
}

struct NoOpBuilder: Builder {
    func buildElement(attributes: [String: String], document: XIBDocument, parent: Reference?) -> Reference? { return parent }
}

public class XIBParser: NSObject {
    public enum Error: Swift.Error {
        case needParent
        case requiredAttribute(attribute: String)
        case invalidAttribute(attribute: String, value: String)
        case unknown(attributes: [String: String])
    }
    private let parser: XMLParser
    private let documentBuilder = DocumentBuilder()

    var builderStack: [Builder] = []
    var stack: [Reference?] = []
    var error: Error?

    public var document: XIBDocument {
        return documentBuilder.document
    }

    public init(data: Data) throws {
        self.parser = XMLParser(data: data)
        super.init()
        self.parser.delegate = self
        try parser.throwingParse()
        if let error = error {
            throw error
        }
    }

    var lastObject: Reference? {
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
        let nextObject: Reference?
        do {
            nextObject = try builder.buildElement(attributes: attributeDict, document: document, parent: lastObject)
        }
        catch let error as XIBParser.Error {
            nextObject = nil
            self.error = error
        }
        catch {
            fatalError("Unknown error thrown")
        }
        builderStack.append(builder)
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


    // Not sure why, but it appears these methods are needed on Linux.
    public func parserDidStartDocument(_ parser: XMLParser) {}
    public func parserDidEndDocument(_ parser: XMLParser) {}
    public func parser(_ parser: XMLParser, foundNotationDeclarationWithName name: String, publicID: String?, systemID: String?) {}
    public func parser(_ parser: XMLParser, foundUnparsedEntityDeclarationWithName name: String, publicID: String?, systemID: String?, notationName: String?) {}
    public func parser(_ parser: XMLParser, foundAttributeDeclarationWithName attributeName: String, forElement elementName: String, type: String?, defaultValue: String?) {}
    public func parser(_ parser: XMLParser, foundElementDeclarationWithName elementName: String, model: String) {}
    public func parser(_ parser: XMLParser, foundInternalEntityDeclarationWithName name: String, value: String?) {}
    public func parser(_ parser: XMLParser, foundExternalEntityDeclarationWithName name: String, publicID: String?, systemID: String?) {}
    public func parser(_ parser: XMLParser, didStartMappingPrefix prefix: String, toURI namespaceURI: String) {}
    public func parser(_ parser: XMLParser, didEndMappingPrefix prefix: String) {}
    public func parser(_ parser: XMLParser, foundIgnorableWhitespace whitespaceString: String) {}
    public func parser(_ parser: XMLParser, foundProcessingInstructionWithTarget target: String, data: String?) {}
    public func parser(_ parser: XMLParser, foundComment comment: String) {}
    public func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {}
    public func parser(_ parser: XMLParser, resolveExternalEntityName name: String, systemID: String?) -> Data? { return nil }
    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Swift.Error) {}
    public func parser(_ parser: XMLParser, validationErrorOccurred validationError: Swift.Error) {}

}
