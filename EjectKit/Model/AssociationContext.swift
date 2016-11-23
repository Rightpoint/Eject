//
//  AssociationContext.swift
//  Eject
//
//  Created by Brian King on 10/26/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

/// AssociationContext modifies the behavior to the KVC behavior that the XML files define
/// The document stores a configuration context which will be used when adding a variable configuration
indirect enum AssociationContext {

    // This will perform a normal assignment
    case assignment

    // This will assume the key refers to an array and call `.append`
    case append

    // This adds support for `forState: .normal`
    case setter(suffix: String)

    // Specify the format of the invocation. This ignores the key and creates prefix + value + suffix. Format was breaking on Linux somehow.
    case invocation(prefix: String, suffix: String, includeTag: Bool)

    // Take any association and add a comment
    case withComment(String, AssociationContext)

    // Inject the value into the object constructor
    case inject

    // Ignore this association
    case ignore
}
