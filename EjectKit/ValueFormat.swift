//
//  ValueFormat.swift
//  Eject
//
//  Created by Brian King on 10/26/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

/// ValueFormat is an enumeration to select the swift representation of a string.
indirect enum ValueFormat {
    case raw
    case number
    case enumeration
    case boolean
    case string
    case image

    // These two cases are overloading the use of this enumeration, but it's easy and I'm sorry.
    case inject(ValueFormat)
    // This is to just inject a string value, no matter what's in the attributes.
    // This is disapointingly needed for UITableView, passing in style and frame, but frame isn't available yet, so pass in .zero and re-configure.
    case injectDefault(String)

    func transform(string value: String) -> String {
        switch self {
        case .raw:
            return value
        case .number:
            return value
        case .enumeration:
            return ".\(value)"
        case .boolean:
            return value == "YES" ? "true" : "false"
        case .string:
            return "\"\(value)\""
        case .image:
            return "UIImage(named: \"\(value)\")"
        case let .inject(format):
            return format.transform(string: value)
        case .injectDefault:
            fatalError("Should not attempt to transform a default injection.")
        }
    }
}
