//
//  Statement.swift
//  Eject
//
//  Created by Brian King on 10/25/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct Statement {
    let declares: Reference?
    let generator: CodeGenerator
    let phase: CodeGeneratorPhase
}
