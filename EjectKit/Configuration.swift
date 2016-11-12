//
//  Configuration.swift
//  Eject
//
//  Created by Brian King on 11/12/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

enum ConstraintConfiguration {
    case anchor
    case anchorage
    var useTranslateAutoresizingMask: Bool {
        return self != .anchorage
    }
}

public struct Configuration {
    var useFrames: Bool = false
    var constraint: ConstraintConfiguration = .anchor
    var selfIdentifier: String? = "-1"
    public init() {}
}
