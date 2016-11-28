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

    public static func load(xml content: String, configuration: Configuration) throws -> XIBDocument {
        guard let data = content.data(using: String.Encoding.utf8) else {
            throw Error.inputIsNotUTF8
        }

        let parser = try XIBParser(data: data, configuration: configuration)
        return parser.document
    }

    /// These are all of the objects declared by the xib. These are tracked for lookup reasons.
    var references: [Reference] = []
    // Some items in the xib initialize child nodes automatically. This is the collection of those child nodes that should be treated as placeholders.
    var placeholders: [String] = []
    // All of the statements declared by the document
    var statements: [Statement] = []
    var variableNameOverrides: [String: (XIBDocument) -> String] = [:]
    var documentInformation: [String: String] = [:]

    var keyOverride: String?
    var containerContext: AssociationContext?

    var configuration: Configuration = Configuration()

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

    public enum Error: Swift.Error {
        case invalidReference(String)
        case inputIsNotUTF8
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

        if object.identifier == configuration.selfIdentifier {
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

    func isPlaceholder(for identifier: String) -> Bool {
        guard let ref = try? self.lookupReference(for: identifier) else { return false }
        return ref.definition.placeholder || placeholders.contains(identifier) || configuration.selfIdentifier == identifier
    }

    func lookupReference(for identifier: String) throws -> Reference {
        for reference in references {
            if reference.identifier == identifier {
                return reference
            }
        }
        throw Error.invalidReference(identifier)
    }

    func hasDependencies(for identifier: String) -> Bool {
        for statement in statements {
            if statement.generator.dependentIdentifiers.contains(identifier) {
                return true
            }
        }
        return false
    }

    func addObject(for identifier: String, definition: ObjectDefinition, customSubclass: String?, userLabel: String?) -> Reference {
        let object = Reference(identifier: identifier, definition: definition, customSubclass: customSubclass, userLabel: userLabel)
        references.append(object)
        return object
    }

    func addVariableConfiguration(for identifier: String, attribute: String, value: CodeGenerator, context: AssociationContext? = nil) throws {
        let obj = try lookupReference(for: identifier)
        let property = obj.definition.property(forAttribute: attribute)

        if let property = property, property.injected {
            // If the property is injected, save the value
            obj.values[property.key.propertyName] = value
        }
        else {
            // Use the key override, the property defined name, or the actual XML attribute name.
            let key = keyOverride ?? property?.key.propertyName ?? attribute

            // Use the container context, the specified context, the property context, or assignment
            let context = containerContext ?? context ?? property?.context ?? .assignment
            addStatement(
                VariableConfiguration(
                    objectIdentifier: identifier,
                    key: key,
                    value: value,
                    style: context
                ),
                phase: .configuration
            )
        }
    }

    func addStatement(_ generator: CodeGenerator, phase: CodeGeneratorPhase, declares: Reference? = nil) {
        let statement = Statement(declares: declares, generator: generator, phase: phase)
        statements.append(statement)
    }

    public func scanForDuplicateVariableNames() {
        var names: [String:[Reference]] = [:]
        for object in references {
            // Don't count objects that don't have any dependencies
            guard hasDependencies(for: object.identifier) else { continue }
            let variable = self.variable(for: object)
            var objects = names[variable] ?? []
            objects.append(object)
            names[variable] = objects
        }
        for (name, objects) in names {
            guard objects.count > 1 else { continue }
            let message = "Variable '\(variable): \(objects[0].className)' was generated \(objects.count) times."
            warnings.append(.duplicateVariable(message))
            for (index, object) in objects.enumerated() {
                variableNameOverrides[object.identifier] = { _ in "\(name)\(index + 1)" }
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
