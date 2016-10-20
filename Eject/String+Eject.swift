//
//  Extensions.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

extension String {

    func snakeCased() -> String {
        var newString = ""
        var previousCharacter: Character? = nil
        for character in characters {
            if previousCharacter == nil {
                newString.append(String(character).lowercased())
            }
            else if previousCharacter == " " {
                newString.append(String(character).uppercased())
            }
            else if character != " " {
                newString.append(character)
            }
            previousCharacter = character
        }
        return newString
    }
}

extension String {

    var floatValue: CGFloat? {
        if let double = Double(self) {
            return CGFloat(double)
        }
        return nil
    }
}
