//
//  FontBuilder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct FontBuilder: Builder {

    func configure(parent: IBGraphable?, attributes: [String: String]) -> IBGraphable {
        guard let parent = parent else { fatalError("No parent to configure") }
        guard let object = parent as? IBReference else { fatalError("parent is not IBReference") }
        guard var key = attributes["key"] else { fatalError("Must specify key") }
        let value: String

        // Not sure why, but the IB specifies a private key. Fix it up.
        if key == "fontDescription" { key = "font" }
        if let type = attributes["type"], let pointSize = attributes["pointSize"], type == "system" {
            value = ".systemFont(ofSize: \(pointSize))"
        }
        else if let pointSize = attributes["pointSize"], let name = attributes["name"] {
            value = "UIFont(name: \"\(name)\", size: \(pointSize))"
        }
        else {
            fatalError("Unknown font \(attributes)")
        }

        object.addVariableConfiguration(for: key, rvalue: BasicRValue(value: value))
        return parent
    }
}
