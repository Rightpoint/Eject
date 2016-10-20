//
//  IBPlaceholder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

public class IBPlaceholder: IBReference {
    weak var document: IBDocument?

    public var identifier: String
    public var className: String
    public var userLabel: String?
    public var generators: [ObjectCodeGenerator] = []

    init (identifier: String, className: String, userLabel: String? = nil) {
        self.identifier = identifier
        self.className = className
        self.userLabel = userLabel
    }
}
