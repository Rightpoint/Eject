//
//  PostProcessor.swift
//  Eject
//
//  Created by Brian King on 11/28/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

public protocol PostProcessor {
    func apply(document: XIBDocument) throws
}

struct DuplicateVariableProcessor: PostProcessor {

    func apply(document: XIBDocument) {
        var names: [String:[Reference]] = [:]
        for object in document.references {
            // Don't count objects that don't have any dependencies
            guard document.hasDependencies(for: object.identifier) else { continue }
            let variable = document.variable(for: object)
            var objects = names[variable] ?? []
            objects.append(object)
            names[variable] = objects
        }
        for (name, objects) in names {
            guard objects.count > 1 else { continue }
            let message = "Variable '\(name): \(objects[0].className)' was generated \(objects.count) times."
            document.warnings.append(.duplicateVariable(message))
            for (index, object) in objects.enumerated() {
                document.variableNameOverrides[object.identifier] = { _ in "\(name)\(index + 1)" }
            }
        }
    }
}
