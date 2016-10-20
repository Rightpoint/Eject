//
//  IBPlaceholder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

class IBPlaceholder: IBReference {
    weak var document: IBDocument?

    var identifier: String
    var className: String
    var userLabel: String?
    var generators: [ObjectCodeGenerator] = []

    init (identifier: String, className: String, userLabel: String? = nil) {
        self.identifier = identifier
        self.className = className
        self.userLabel = userLabel
    }
}
