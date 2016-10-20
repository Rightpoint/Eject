//
//  Builders.swift
//  Eject
//
//  Created by Brian King on 10/17/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation



struct OptionSetBuilder: Buildable {

    func configure(parent: IBGraphable?, attributes: [String: String]) -> IBGraphable {
        guard let object = parent as? IBReference else { fatalError("No parent to configure") }
        var attributes = attributes
        guard let key = attributes.removeValue(forKey: "key") else {
            fatalError("Invalid Nil")
        }
        object.addVariableConfiguration(for: key, valueGenerator: OptionSetValue(attributes: attributes))
        return object
    }

}

extension String {

    var float: CGFloat? {
        if let double = Double(self) {
            return CGFloat(double)
        }
        else {
            return nil
        }
    }

}
