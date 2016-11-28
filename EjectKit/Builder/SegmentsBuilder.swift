//
//  SegmentsBuilder.swift
//  Eject
//
//  Created by Brian King on 10/26/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct SegmentsBuilder: Builder, ContainerBuilder {

    func buildElement(attributes: inout [String: String], document: XIBDocument, parent: Reference?) -> Reference? {
        document.containerContext = .invocation(prefix: "insertSegment(", suffix: ", at: 0, animated: false)", includeTag: true)
        return parent
    }

    func complete(document: XIBDocument) {
        document.containerContext = nil
    }

    func didAddChild(object: Reference, to parent: Reference, document: XIBDocument) {
        guard let context = document.containerContext, case let .invocation(prefix, suffix, includeTag) = context else {
            fatalError("Error with Child")
        }
        var components = suffix.components(separatedBy: " ")
        let index = Int(components[2]) ?? 0
        components[2] = "\(index + 1),"
        document.containerContext = .invocation(prefix: prefix, suffix: components.joined(separator: " "), includeTag: includeTag)
    }

    struct Segment: Builder {
        func buildElement(attributes: inout [String: String], document: XIBDocument, parent: Reference?) throws -> Reference? {
            guard let parent = parent else { throw XIBParser.Error.needParent }
            for (key, tag, format) in [("title", "withTitle", ValueFormat.string), ("image", "with", ValueFormat.image)] {
                if let value = attributes.removeValue(forKey: key) {
                    try document.addVariableConfiguration(
                        for: parent.identifier,
                        attribute: tag,
                        value: BasicValue(value: value, format: format)
                    )
                }
            }
            return parent
        }
    }
}

