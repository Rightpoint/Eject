//
//  main.swift
//  Eject
//
//  Created by Brian King on 10/26/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation
import EjectKit

func printUsage(errorMessage: String? = nil) -> Never {
    if let errorMessage = errorMessage {
        print(errorMessage + "\n")
    }
    print([
        " Eject:",
        "",
        " --file <path>.xib",
        "",
        " Example:",
        "    eject --file ./MassiveViewController.xib",
        ].joined(separator: "\n"))
    exit(0)
}
let arguments = CommandLine.arguments.dropFirst()

guard !arguments.contains("-h") && !arguments.contains("--help") && arguments.count == 2 && arguments.first == "--file" else {
    printUsage()
}

let path = URL(fileURLWithPath: arguments.last!)
print("Generating Code for xib at path: " + path.path + "\n")

guard path.pathExtension == "xib" else {
    printUsage(errorMessage: "File must specify a xib file")
}

do {
    let data = try Data(contentsOf: path)
    let builder = try XIBParser(data: data)
    let code = builder.document.generateCode()
    print(code.joined(separator: "\n"))
}
catch {
    print("Error: ")
    print("")
    print(error)
}


