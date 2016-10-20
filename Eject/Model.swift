//
//  Model.swift
//  Eject
//
//  Created by Brian King on 10/17/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

/// An object that can be held inside the graph
protocol IBGraphable: class {
    var document: IBDocument? { get }
}

/// An object that references something in the object graph that enerates code
protocol IBReference: IBGraphable {
    var identifier: String { get }
    var generators: [ObjectCodeGenerator] { get set }

    func configurationGenerator(for key: String, rvalue: CodeGenerator) -> ObjectCodeGenerator
}


/// Base class that models the state of a xib file. Eject assumes that the file to be generated
/// is either the file owner, or the first view in the objects array with a custom class configured.
class IBDocument: IBGraphable {

    /// These connections are all of the properties that were exposed by the xib file.
    var connections: [IBOutlet] = []

    /// These are all of the objects declared by the xib. These are tracked for lookup reasons.
    var references: [IBReference] = []

    /// Generate a variable property name with the following precedence
    ///
    /// - IBOutlet property name
    /// - User Label joined and camel cased
    /// - Class name without the prefix
    func variable(for object: IBObject) -> String {
        for placeholder in connections {
            if placeholder.destinationIdentifier == object.identifier {
                return placeholder.property
            }
        }
        var components = object.userLabel?.components(separatedBy: .whitespaces) ?? []
        if components.count == 1 {
            return components[0].lowercased()
        }
        else if components.count > 1 {
            let first = components[0].lowercased()
            components.replaceSubrange(0...1, with: [first])
            return components.joined()
        }
        var className = object.className
        for prefix in ["NS", "UI", "MK", "SCN"] {
            if let range = className.range(of: prefix) {
                className.removeSubrange(range)
                return className
            }
        }
        // This is the last resort and will not compile.
        return object.identifier
    }

    enum Scope {
        case local
        case property
    }

    func scope(for object: IBObject) -> Scope {
        for placeholder in connections {
            if placeholder.destinationIdentifier == object.identifier {
                return .property
            }
        }
        return .local
    }

    func lookupObject(for identifier: String) -> IBObject {
        for object in references {
            if object.identifier == identifier {
                guard let object = object as? IBObject else {
                    fatalError("Identifier \(identifier) is not an object")
                }
                return object
            }
        }
        fatalError("Unknown identifier \(identifier)")
    }

    func addObject(for identifier: String, className: String, userLabel: String?, parent: IBObject?) -> IBObject {
        let object = IBObject(identifier: identifier, className: className, userLabel: userLabel)
        object.document = self
        references.append(object)
        parent?.children.append(object)
        return object
    }

    var document: IBDocument? {
        return self
    }

}

class IBObject: IBReference {
    weak var document: IBDocument?
    weak var parent: IBObject?
    var children: [IBObject] = []

    var identifier: String
    var className: String
    var userLabel: String?
    var generators: [ObjectCodeGenerator] = []

    fileprivate init (identifier: String, className: String, userLabel: String? = nil) {
        self.identifier = identifier
        self.className = className
        self.userLabel = userLabel
    }

    var variableName: String {
        if let userLabel = userLabel {
            let parts = userLabel.components(separatedBy: .whitespaces).map() { $0.capitalized }.joined()
            return parts
        }
        else {
            return className
        }
    }

    func addOutlet(for identifier: String, property: String, destinationIdentifier: String) -> IBOutlet {
        return IBOutlet(object: self, identifier: identifier, property: property, destinationIdentifier: destinationIdentifier)
    }

    func addDeclaration(arguments: [String: String]) {
        let declaration = Declaration(objectIdentifier: identifier, className: className, arguments: arguments)
        generators.append(declaration)
    }
}

class IBOutlet: IBReference {
    var document: IBDocument? {
        return object?.document
    }
    weak var object: IBObject?
    var generators: [ObjectCodeGenerator] = []

    var identifier: String
    var property: String
    var destinationIdentifier: String
    fileprivate init(object: IBObject, identifier: String, property: String, destinationIdentifier: String) {
        self.object = object
        self.identifier = identifier
        self.property = property
        self.destinationIdentifier = destinationIdentifier
    }
}

extension IBReference {

    // Default implementation
    func configurationGenerator(for key: String, rvalue: CodeGenerator) -> ObjectCodeGenerator {
        return VariableConfiguration(objectIdentifier: identifier, key: key, value: rvalue, setterContext: nil)
    }

    func addVariableConfiguration(for key: String, rvalue: CodeGenerator) {
        let generator = configurationGenerator(for: key, rvalue: rvalue)
        generators.append(generator)
    }
}
