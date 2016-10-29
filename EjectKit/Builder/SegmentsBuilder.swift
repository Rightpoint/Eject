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
        document.containerContext = .setter(suffix: "forSegmentAt: 0")
        return parent
    }

    func complete(document: XIBDocument) {
        document.containerContext = nil
    }

    func didAddChild(object: Reference, to parent: Reference, document: XIBDocument) {
        guard let context = document.containerContext, case let .setter(suffix) = context else {
            fatalError("Error with Child")
        }
        var components = suffix.components(separatedBy: " ")
        let index = Int(components[1]) ?? 0
        components[1] = String(index + 1)
        document.containerContext = .setter(suffix: components.joined(separator: " "))
    }

    struct Segment: Builder {
        func buildElement(attributes: inout [String: String], document: XIBDocument, parent: Reference?) throws -> Reference? {
            guard let parent = parent else { throw XIBParser.Error.needParent }
            for (key, format) in [("title", ValueFormat.string), ("image", ValueFormat.image)] {
                if let value = attributes.removeValue(forKey: key) {
                    document.addVariableConfiguration(for: parent.identifier, key: key, value: BasicValue(value: value, format: format))
                }
            }
            return parent
        }
    }
}

