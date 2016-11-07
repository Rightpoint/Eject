//
//  XIBParser.swift
//  Eject
//
//  Created by Brian King on 10/17/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

protocol Builder {
    func buildElement(attributes: inout [String: String], document: XIBDocument, parent: Reference?) throws -> Reference?
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

public class XIBParser: NSObject {
    public enum Error: Swift.Error {
        case needParent
        case requiredAttribute(attribute: String)
        case invalidAttribute(attribute: String, value: String)
        case unknown(attributes: [String: String])
    }
    private let documentBuilder = DocumentBuilder()

    var builderStack: [Builder] = []
    var stack: [Reference?] = []
    var elementStack: [String] = []
    var error: Error? {
        didSet {
            #if STOCK_PARSER
                parser.abortParsing()
            #endif
        }
    }

    public var document: XIBDocument {
        return documentBuilder.document
    }

#if STOCK_PARSER
    private let parser: XMLParser
    public init(data: Data) throws {
        self.parser = XMLParser(data: data)
        super.init()
        self.parser.delegate = self
        try parser.throwingParse()
        if let error = error {
            throw error
        }
    }
#else
    public init(data: Data) throws {
        super.init()
        try data.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) throws -> Void  in
            let buffer = UnsafeBufferPointer(start: ptr, count: data.count)
            var parser = SimpleXMLParser(input: buffer)
            try parser.parse() { [unowned self] event in
                switch event {
                case let .enter(elementName, attributes):
                    self.enterElement(elementName: elementName, attributes: attributes)
                case let .exit(elementName):
                    self.exitElement(elementName: elementName)
                case let .body(string):
                    self.foundCharacters(string: string)
                }
            }
        }
    }
#endif

    var lastObject: Reference? {
        return stack.last ?? nil
    }

    var lastBuilder: Builder? {
        return builderStack.last
    }

    var builderLookup: BuilderLookup {
        return documentBuilder
    }

    func enterElement(elementName: String, attributes: [String: String]) {
        guard let builder = builderLookup.lookupBuilder(for: elementName) else {
            document.missingBuilder(forElement: elementName)
            return
        }
        let nextObject: Reference?
        var attributes = attributes
        do {
            nextObject = try builder.buildElement(attributes: &attributes, document: document, parent: lastObject)
        }
        catch let error as XIBParser.Error {
            nextObject = nil
            self.error = error
        }
        catch {
            fatalError("Unknown error thrown")
        }
        elementStack.append(elementName)
        builderStack.append(builder)
        stack.append(nextObject)
        if attributes.count > 0 {
            let attrs = attributes.map() { "\($0)='\($1)'" }.joined(separator: ", ")
            let missing = elementStack.joined(separator: ".").appending(": \(attrs)")
            document.warnings.append(.unknownAttribute(missing))
        }
    }

    func exitElement(elementName: String) {
        guard builderLookup.lookupBuilder(for: elementName) != nil else {
            return
        }
        elementStack.removeLast()
        let object = stack.removeLast()
        let completedBuilder = builderStack.removeLast()
        completedBuilder.complete(document: document)

        if let lastBuilder = lastBuilder as? ContainerBuilder, let object = object {
            lastBuilder.didAddChild(object: object, to: lastObject!, document: document)
        }
    }

    func foundCharacters(string: String) {
        guard let characterBuilder = lastBuilder as? CharacterBuilder else {
            return
        }
        characterBuilder.found(characters: string)
    }

}

extension XIBParser: XMLParserDelegate {
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        enterElement(elementName: elementName, attributes: attributeDict)
    }

    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        exitElement(elementName: elementName)
    }

    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        foundCharacters(string: string)
    }

}
