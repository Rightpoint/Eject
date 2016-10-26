//
//  IBDocument.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

/// Class that models the state of a xib file.
public class IBDocument {

    public static func load(xml content: String) throws -> IBDocument {
        guard let data = content.data(using: String.Encoding.utf8) else {
            fatalError("Unable to convert to UTF8")
        }

        let parser = try XIBParser(data: data)
        return parser.document
    }

    /// These are all of the objects declared by the xib. These are tracked for lookup reasons.
    public var references: [IBReference] = []
    var statements: [Statement] = []
    var containerContext: ConfigurationContext?

    /// Generate a variable property name with the following precedence
    ///
    /// - User Label joined and camel cased
    /// - Class name without the prefix
    func variable(for object: IBReference) -> String {
        if object.identifier == "-1" {
            return "self"
        }
        if let userLabel = object.userLabel {
            return userLabel.snakeCased()
        }
        var className = object.className
        for prefix in ["NS", "UI", "MK", "SCN"] {
            if let range = className.range(of: prefix) {
                className.removeSubrange(range)
            }
        }
        return className.snakeCased()
    }

    func lookupReference(for identifier: String) -> IBReference {
        for reference in references {
            if reference.identifier == identifier {
                return reference
            }
        }
        fatalError("Unknown identifier \(identifier)")
    }

    enum Declaration {
        case initializer([String: String])
        case invocation(CodeGenerator)
    }

    func addObject(for identifier: String, className: String, userLabel: String?, declaration: Declaration, phase: CodeGeneratorPhase) -> IBObject {
        let object = IBObject(identifier: identifier, className: className, userLabel: userLabel)
        references.append(object)

        let generator: CodeGenerator
        switch declaration {
        case let .initializer(arguments):
            generator = Initializer(objectIdentifier: identifier, className: className, arguments: arguments)
        case let .invocation(invocation):
            generator = invocation
        }
        addStatement(generator, phase: phase, declares: object)

        return object
    }

    func addPlaceholder(for identifier: String, className: String, userLabel: String?) -> IBPlaceholder {
        let object = IBPlaceholder(identifier: identifier, className: className, userLabel: userLabel)
        references.append(object)
        return object
    }

    func addVariableConfiguration(for identifier: String, key: String, value: CodeGenerator, context: ConfigurationContext = .assignment) {
        addStatement(
            VariableConfiguration(
                objectIdentifier: identifier,
                key: key,
                value: value,
                style: containerContext ?? context
            ),
            phase: .configuration
        )
    }

    func addStatement(_ generator: CodeGenerator, phase: CodeGeneratorPhase, declares: IBReference? = nil) {
        let statement = Statement(declares: declares, generator: generator, phase: phase)
        statements.append(statement)
    }

}
