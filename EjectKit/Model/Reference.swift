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

    let identifier: String
    let className: String
    let userLabel: String?
    var values: [String: CodeGenerator] = [:]

    init(identifier: String, className: String, userLabel: String?) {
        self.identifier = identifier
        self.className = className
        self.userLabel = userLabel?.components(separatedBy: Reference.invalidCharacterSet).joined(separator: " ")
    }
}
