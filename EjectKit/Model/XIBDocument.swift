//
//  XIBDocument.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation


/// Class that models the state of a xib file.
public class XIBDocument {

    public static func load(xml content: String) throws -> XIBDocument {
        guard let data = content.data(using: String.Encoding.utf8) else {
            fatalError("Unable to convert to UTF8")
        }

        let parser = try XIBParser(data: data)
        return parser.document
    }

    /// These are all of the objects declared by the xib. These are tracked for lookup reasons.
    var statements: [Statement] = []
    var references: [Reference] = []
    var keyOverride: String?
    var containerContext: ConfigurationContext?
    var selfIdentifier = "-1"
    var variableNameOverrides: [String: (XIBDocument) -> String] = [:]
    var documentInformation: [String: String] = [:]
    public enum Warning {
        case unknownAttribute(String)
        case unknownElementName(String)
        case duplicateVariable(String)

        public var message: String {
            switch self {
            case let .unknownAttribute(message):
                return message
            case let .duplicateVariable(message):
                return message
            case let .unknownElementName(message):
                return message
            }
        }
    }
    public var warnings: [Warning] = []
    var missingElementNames: Set<String> = []

    /// Generate a variable property name with the following precedence
    ///
    /// - A variable name that was explicitely specified
    /// - User Label joined and camel cased
    /// - Class name without the prefix
    func variable(for object: Reference) -> String {
        let variable: String

        if object.identifier == selfIdentifier {
            variable = "self"
        }
        else if let userLabel = object.userLabel {
            variable = userLabel.snakeCased()
        }
        else if let variableName = variableNameOverrides[object.identifier] {
            variable = variableName(self)
        }
        else {
            var className = object.className
            if let range = className.range(of: className.objcNamespace()) {
                className.removeSubrange(range)
            }
            variable = className.snakeCased()
        }
        return variable
    }

    func lookupReference(for identifier: String) throws -> Reference {
        for reference in references {
            if reference.identifier == identifier {
                return reference
            }
        }
        fatalError("Unknown identifier \(identifier)")
    }

    func hasDependencies(for identifier: String) -> Bool {
        for statement in statements {
            if statement.generator.dependentIdentifiers.contains(identifier) {
                return true
            }
        }
        return false
    }

    enum Declaration {
        case placeholder
        case initializer([String], CodeGeneratorPhase)
        case invocation(CodeGenerator, CodeGeneratorPhase)
    }

    func addObject(for identifier: String, className: String, userLabel: String?, declaration: Declaration) -> Reference {
        let object = Reference(identifier: identifier, className: className, userLabel: userLabel)
        references.append(object)

        switch declaration {
        case .placeholder:
            break
        case let .initializer(injectedProperties, phase):
            let generator = Initializer(objectIdentifier: identifier, className: className, injectedProperties: injectedProperties)
            addStatement(generator, phase: phase, declares: object)
        case let .invocation(invocation, phase):
            let generator = invocation
            addStatement(generator, phase: phase, declares: object)
        }

        return object
    }

    func addVariableConfiguration(for identifier: String, key: String, value: CodeGenerator, context: ConfigurationContext = .assignment) throws {
        addStatement(
            VariableConfiguration(
                objectIdentifier: identifier,
                key: keyOverride ?? key,
                value: value,
                style: containerContext ?? context
            ),
            phase: .configuration
        )
        // Save the key / CodeGenerator. These can be used by Initializer to inject values
        let obj = try lookupReference(for: identifier)
        obj.values[key] = value
    }

    func addStatement(_ generator: CodeGenerator, phase: CodeGeneratorPhase, declares: Reference? = nil) {
        let statement = Statement(declares: declares, generator: generator, phase: phase)
        statements.append(statement)
    }

    public func scanForDuplicateVariableNames() {
        var names: Set<String> = []
        var warned: Set<String> = []
        for object in references {
            // Don't count objects that don't have any dependencies
            guard hasDependencies(for: object.identifier) else { continue }
            let variable = self.variable(for: object)
            if names.contains(variable) && !warned.contains(variable) {
                let message = "Variable '\(variable): \(object.className)' was generated multiple times."
                warnings.append(.duplicateVariable(message))
                warned.insert(variable)
            }
            else {
                names.insert(variable)
            }
        }
    }

    func missingBuilder(forElement element: String) {
        if !missingElementNames.contains(element) {
            warnings.append(.unknownElementName("Can not configure XML nodes '\(element)'"))
        }
        missingElementNames.insert(element)
    }

}
