//
//  Configuration.swift
//  Eject
//
//  Created by Brian King on 11/12/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

/// Simple configuration struct.
public struct Configuration {
    var useFrames: Bool = true
    var includeComments: Bool = true
    public var constraint: ConstraintConfiguration = .anchor
    public var postprocessors: [PostProcessor] = [DuplicateVariableProcessor(), TargetActionConfiguration.PostProcessor()]
    var selfIdentifier: String? = nil
    public init() {	}
}

public enum ConstraintConfiguration: String {
    case anchor = "NSLayoutAnchor"
    case anchorage = "Anchorage"
    var useTranslateAutoresizingMask: Bool {
        return self != .anchorage
    }
}

