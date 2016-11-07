//
//  SimpleXMLParserTests.swift
//  Eject
//
//  Created by Brian King on 11/7/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import XCTest
import EjectKit

class EmptyXMLDelegate: NSObject, XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {}
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {}
    func parser(_ parser: XMLParser, foundCharacters string: String) {}
}


class XMLParserTests: XCTestCase {
    typealias XMLCheck = (UInt, String, [SAXEvent])
    func perform(xmlChecks checkList: [XMLCheck]) {
        for xmlCheck in checkList {
            var events: [SAXEvent] = []

            do {
                try SimpleXMLParser.parse(string: xmlCheck.1) { event in
                    events.append(event)
                }
            } catch let error {
                XCTAssertNil(error, line: xmlCheck.0)
            }
            XCTAssertEqual(events, xmlCheck.2, line: xmlCheck.0)
        }

    }

    func testValidXML() {
        let xmlChecks: [XMLCheck] = [
            (#line, "<node></node>", [.enter(elementName:"node", attributes: [:]), .exit(elementName: "node")]),
            (#line, "<node/>", [.enter(elementName:"node", attributes: [:]), .exit(elementName: "node")]),
            (#line, "<node foo='bar'></node>", [.enter(elementName:"node", attributes: ["foo": "bar"]), .exit(elementName: "node")]),
            (#line, "<node foo=''></node>", [.enter(elementName:"node", attributes: ["foo": ""]), .exit(elementName: "node")]),
            (#line, "This is <A>A style</A> test for <B>B Style</B>.", [
                .body(string: "This is "),
                .enter(elementName:"A", attributes: [:]),
                .body(string: "A style"),
                .exit(elementName: "A"),
                .body(string: " test for "),
                .enter(elementName:"B", attributes: [:]),
                .body(string: "B Style"),
                .exit(elementName: "B"),
                .body(string: "."),
                ]),
            (#line, "<node foo='bar'>body</node>", [
                .enter(elementName:"node", attributes: ["foo": "bar"]),
                .body(string: "body"),
                .exit(elementName: "node")]),
            (#line, "<node><in></in></node>", [
                .enter(elementName:"node", attributes: [:]), .enter(elementName:"in", attributes: [:]),
                .exit(elementName: "in"), .exit(elementName: "node")]),
            (#line, "<node><in/></node>", [
                .enter(elementName:"node", attributes: [:]), .enter(elementName:"in", attributes: [:]),
                .exit(elementName: "in"), .exit(elementName: "node")]),
            (#line, "<  node  foo = ' bar ' ></ node >", [.enter(elementName:"node", attributes: ["foo": " bar "]), .exit(elementName: "node")]),
            // The parser doesn't need a root element. This is intended because XML fragments shipped in JSON frequently do not have a root node.
            (#line, "openBody<node></node>closeBody", [
                .body(string: "openBody"),
                .enter(elementName:"node", attributes: [:]), .exit(elementName: "node"),
                .body(string: "closeBody")]),
            (#line, "openBody<node>innerBody</node>closeBody", [
                .body(string: "openBody"),
                .enter(elementName:"node", attributes: [:]), .body(string: "innerBody"), .exit(elementName: "node"),
                .body(string: "closeBody")]),
            ]
        perform(xmlChecks: xmlChecks)
    }

    static var performanceString: String = {
        var hugeString = "<H>"
        for _ in 0..<1000 {
            hugeString.append("This is <A>A style</A> test for <B>B Style</B>.")
        }
        hugeString.append("</H>")
        return hugeString
    }()

    func testLargeStringSimplePerformance() {
        // 0.101s(3%) on iPhone 4s (9.3)
        measure() {
            do {
                try SimpleXMLParser.parse(string: XMLParserTests.performanceString) { event in }
            } catch let error {
                XCTAssertNil(error)
            }
        }
    }

    /// Baseline performance test for the stock XML parser.
    func testLargeStringStockPerformance() {
        measure() {
            // 0.127s(2%) on iPhone 4s (9.3)
            guard let data = XMLParserTests.performanceString.data(using: String.Encoding.utf8) else {
                fatalError("Unable to convert to UTF8")
            }
            let delegate = EmptyXMLDelegate()
            let stockParser = XMLParser(data: data)
            stockParser.shouldProcessNamespaces = false
            stockParser.shouldReportNamespacePrefixes = false
            stockParser.shouldResolveExternalEntities = false
            stockParser.delegate = delegate
            stockParser.parse()

            XCTAssertNil(stockParser.parserError)
        }
    }
}
