//
//  Model.swift
//  Eject
//
//  Created by Brian King on 10/17/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct Document {
    var type: String = ""
    var version: String = ""

    var placeholders: [Placeholder] = []
    var objects: [IBObject] = []

    func object(for identifier: String) -> IBObject {
        fatalError()
    }
}

struct IBObject {
    var identifier: String = ""
    var customClass: String?
    var userLabel: String?
    var configuration: [ConfigurationRepresentation] = []
}

class Placeholder {
    var connections: [Outlet] = []
}

class Outlet {
    var identifier: String = ""
    var property: String = ""
    var destination: IBObject?
}

protocol ConfigurationRepresentation {
    func representation(forVariable: String) -> String
}

protocol ValueRepresentable {
    var representation: String { get }
}

struct Property<T: ValueRepresentable>: ConfigurationRepresentation {
    var key: String = ""
    var valueRepresentable: T

    func representation(forVariable: String) -> String {
        return "\(forVariable).\(key) = \(valueRepresentable.representation)"
    }
}

struct SubviewProperty: ConfigurationRepresentation {
    var subviews: [IBObject]

    func representation(forVariable: String) -> String {
        return "\(forVariable).subviews = []"
    }
}

class ConstraintProperty: ConfigurationRepresentation {
    func representation(forVariable: String) -> String {
        return ""
    }
}
