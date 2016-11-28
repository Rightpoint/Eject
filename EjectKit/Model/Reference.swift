//
//  Reference.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

/// A class to represent an object in the graph
public class Reference {
    static let invalidCharacterSet: CharacterSet = {
        var characterSet = CharacterSet.alphanumerics
        characterSet.insert(charactersIn: "_")
        return characterSet.inverted
    }()

    let definition: ObjectDefinition
    let identifier: String
    let userLabel: String?
    let customSubclass: String?
    var values: [String: CodeGenerator] = [:]
    var statements: [Statement] = []

    init(identifier: String, definition: ObjectDefinition, customSubclass: String?, userLabel: String?) {
        self.identifier = identifier
        self.definition = definition
        self.customSubclass = customSubclass
        self.userLabel = userLabel?.components(separatedBy: Reference.invalidCharacterSet).joined(separator: " ")
    }

    var className: String {
        return customSubclass ?? definition.className
    }
}
