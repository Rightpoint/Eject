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
    case transformed([String: String], ValueFormat)

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
        case let .transformed(mapping, format):
            return format.transform(string: mapping[value] ?? value)
        }
    }
}
