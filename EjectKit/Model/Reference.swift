//
//  Reference.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

/// A struct that references an object in the graph
public struct Reference {
    let identifier: String
    let className: String
    let userLabel: String?
}
