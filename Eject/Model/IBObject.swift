//
//  IBObject.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

class IBObject: IBReference {
    weak var document: IBDocument?
    weak var parent: IBObject?
    var children: [IBObject] = []

    var identifier: String
    var className: String
    var userLabel: String?
    var generators: [ObjectCodeGenerator] = []

    init (identifier: String, className: String, userLabel: String? = nil) {
        self.identifier = identifier
        self.className = className
        self.userLabel = userLabel
    }

    var variableName: String {
        if let userLabel = userLabel {
            let parts = userLabel.components(separatedBy: .whitespaces).map() { $0.capitalized }.joined()
            return parts
        }
        else {
            return className
        }
    }

    func addDeclaration(arguments: [String: String]) {
        let declaration = Declaration(objectIdentifier: identifier, className: className, arguments: arguments)
        generators.append(declaration)
    }
}
