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
    var className: String { get }
    var userLabel: String? { get }
    var generators: [ObjectCodeGenerator] { get set }

    func configurationGenerator(for key: String, rvalue: CodeGenerator) -> ObjectCodeGenerator
}


/// Base class that models the state of a xib file. Eject assumes that the file to be generated
/// is either the file owner, or the first view in the objects array with a custom class configured.
class IBDocument: IBGraphable {

    /// These are all of the objects declared by the xib. These are tracked for lookup reasons.
    var references: [IBReference] = []

    /// Generate a variable property name with the following precedence
    ///
    /// - User Label joined and camel cased
    /// - Class name without the prefix
    func variable(for object: IBReference) -> String {
        if let userLabel = object.userLabel {
            return userLabel.snakeCased()
        }
        var className = object.className
        for prefix in ["NS", "UI", "MK", "SCN"] {
            if let range = className.range(of: prefix) {
                className.removeSubrange(range)
                return className.snakeCased()
            }
        }
        // This is the last resort and will not compile.
        return object.identifier
    }

    enum Scope {
        case local
        case property
    }

    func scope(for object: IBReference) -> Scope {
//        for placeholder in connections {
//            if placeholder.destinationIdentifier == object.identifier {
//                return .property
//            }
//        }
        return .local
    }

    func lookupReference(for identifier: String) -> IBReference {
        for reference in references {
            if reference.identifier == identifier {
                return reference
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

    func addPlaceholder(for identifier: String, className: String, userLabel: String?) -> IBPlaceholder {
        let object = IBPlaceholder(identifier: identifier, className: className, userLabel: userLabel)
        object.document = self
        references.append(object)
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

    func addDeclaration(arguments: [String: String]) {
        let declaration = Declaration(objectIdentifier: identifier, className: className, arguments: arguments)
        generators.append(declaration)
    }
}

class IBPlaceholder: IBReference {
    weak var document: IBDocument?

    var identifier: String
    var className: String
    var userLabel: String?
    var generators: [ObjectCodeGenerator] = []

    fileprivate init (identifier: String, className: String, userLabel: String? = nil) {
        self.identifier = identifier
        self.className = className
        self.userLabel = userLabel
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
