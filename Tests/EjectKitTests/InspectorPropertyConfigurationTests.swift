//
//  InspectorPropertyConfigurationTests.swift
//  Eject
//
//  Created by Brian King on 10/24/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation
import XCTest
@testable import EjectKit

class InspectorPropertyConfigurationTests: XCTestCase {

    // Uncomment this to create a populated DocumentBuilder
    func skip_testBasic() {
        let url = URL(fileURLWithPath: "/Applications/Xcode.app/Contents/PlugIns/IDEInterfaceBuilderCocoaTouchIntegration.ideplugin/Contents/Resources/")
        let output = try? InspectorParser.helperCode(for: url)
        if output != nil {
            print(output!)
        }
    }
}

// This class helps build the DocumentBuilders by parsing some of Interface Builder's XML files
// The goal of this file is just to help populate the scope of UIKit properties, not create code that will compile without assistance.
//
// Steps:
//  - Split up into view, gesture recognizers, controls and view controllers
//  - Scan through and merge in the additions
//  - Update inheritance, only some are done automatically
//  - Merge UITextInputTraits into text view and text field
//  - Update UITableView constructor
//  - Update UIImageView to supply image
//  - Add 'text' to UILabel
class InspectorParser: NSObject, XMLParserDelegate {

    static func helperCode(for directory: URL) throws -> String {
        let files = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [])
        let inspectors = files.filter() { $0.pathExtension == "inspector" }
        var helpers: [String] = []
        for file in inspectors {
            let parser = try InspectorParser(path: file)
            let helperCode = parser.helperCode
            if helperCode != "" {
                helpers.append(helperCode)
            }
        }
        return "// Configuration from \(directory.absoluteString)\n\n\(helpers.joined(separator: "\n\n"))"
    }

    private let embededTypes = ["boolean", "number", "enumeration"]
    private let parser: XMLParser
    private let guessedClassName: String
    private let guessedElementName: String
    private var properties: [String]

    init(path: URL) throws {
        let data = try Data(contentsOf: path)
        var file = path.lastPathComponent
        if let prefixRange = file.range(of: "IB") {
            file.removeSubrange(prefixRange)
        }
        if let suffixRange = file.range(of: ".inspector") {
            file.removeSubrange(suffixRange)
        }
        guessedClassName = file
        if let prefixRange = file.range(of: "UI") {
            file.removeSubrange(prefixRange)
        }
        guessedElementName = file.snakeCased()
        self.parser = XMLParser(data: data)
        self.properties = []
        super.init()
        self.parser.delegate = self
        try parser.throwingParse()
    }

    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName == "property" {
            guard let type = attributeDict["type"]?.lowercased(),
                let keyPath = attributeDict["keyPath"] ?? attributeDict["configurableProperty"] else {
                    print("[\(guessedClassName)] Invalid \(attributeDict)")
                    return
            }
            // This is a property that is not configured inside an element attributes, but in a child node. These are globally registered,
            // and can be ignored here
            guard embededTypes.contains(type) else { return }

            // This pattern appears to use valid keypaths, with a relay through the internal controller. Strip out that keypath part.
            guard let newKeyPath = keyPath.components(separatedBy: ".").last else {
                fatalError("This is not expected")
            }

            // Some of the inspector properties have more brains than we can deal with automatically. Ignore them here, they will have to
            // be handled later
            guard !keyPath.hasPrefix("inspectedObjectsController.selection.object.ibInspect") && !newKeyPath.hasPrefix("ib") && !newKeyPath.contains("_") else {
                print("[\(guessedClassName)] Ignoring \(attributeDict)")
                return
            }

            properties.append("(\"\(newKeyPath)\", .\(type))")
        }
    }

    var helperCode: String {
        guard properties.count > 0 else {
            return ""
        }

        if !guessedClassName.contains("-") {
            let viewSubclass = guessedClassName.contains("View") && !guessedClassName.contains("ViewController")
            let creator = viewSubclass ? "view.inherit(" : "ObjectBuilder("
            return [
                "// Class: \(guessedClassName)",
                "let \(guessedElementName) = \(creator)",
                "    className: \"\(guessedClassName)\",",
                "    properties: [\(properties.joined(separator: ", "))]",
                ")",
                "register(\"\(guessedElementName)\", \(guessedElementName))",
                ""
                ].joined(separator: "\n")
        }
        else {
            // This is an addition file, just note the properties
            return [
                "// Append Class: \(guessedClassName)",
                "//    properties: \(properties.joined(separator: ", "))",
            ].joined(separator: "\n")
        }
    }

    #if os(Linux)
    public func parserDidStartDocument(_ parser: XMLParser) {}
    public func parserDidEndDocument(_ parser: XMLParser) {}
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {}
    public func parser(_ parser: XMLParser, foundCharacters string: String) {}
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
    // Aaaand, it's NSError, not Error on Linux.
    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: NSError) {}
    public func parser(_ parser: XMLParser, validationErrorOccurred validationError: NSError) {}
    #endif

}
