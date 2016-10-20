//
//  IBObject.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

public class IBObject: IBReference {
    weak var document: IBDocument?
    weak var parent: IBObject?
    var children: [IBObject] = []

    public var identifier: String
    public var className: String
    public var userLabel: String?
    public var generators: [ObjectCodeGenerator] = []

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
