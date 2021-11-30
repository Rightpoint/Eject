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
    printWarning(message:[
        " Eject:",
        "",
        " --file <path>.xib [--anchorage]",
        "",
        " Example:",
        "    eject --file ./MassiveViewController.xib --anchorage",
        ].joined(separator: "\n"))
    exit(0)
}
func printWarning(message: String) {
    let e = FileHandle.standardError
    e.write(message.appending("\n").data(using: String.Encoding.utf8)!)
}

let arguments = CommandLine.arguments

guard !arguments.contains("-h") && !arguments.contains("--help") && (arguments.count == 3 || arguments.count == 4) && arguments[1] == "--file" else {
    printUsage()
}

let path = URL(fileURLWithPath: arguments[2])
let configuration = Configuration(arguments.last == "--anchorage" ? .anchorage : .anchor)

do {
    let data = try Data(contentsOf: path)
    let builder = try XIBParser(data: data, configuration: configuration)
    printWarning(message: builder.document.warnings.map() { $0.message }.joined(separator: "\n"))

    let code = try builder.document.generateCode()
    print(code.joined(separator: "\n"))
}
catch {
    printWarning(message: "Error: \(error)")
}

