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

struct Configuration {
    let useFrames: Bool = false
    let constrant: ConstraintConfiguration = .anchorage
    let selfIdentifier: String? = "-1"
}
