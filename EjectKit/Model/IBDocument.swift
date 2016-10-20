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
            }
        }
        return className.snakeCased()
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
