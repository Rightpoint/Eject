//
//  PlaceholderBuilder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct PlaceholderBuilder: Builder {

    func configure(parent: IBGraphable?, attributes: [String: String]) -> IBGraphable {
        guard let parent = parent, let document = parent.document else { fatalError("ObjectBuilder must have a parent") }
        guard let identifier = attributes["id"] else { fatalError("Must have identifier") }
        let className = attributes["customClass"] ?? "NSObject"
        let placeholder = document.addPlaceholder(for: identifier,
                                                  className: className,
                                                  userLabel: attributes["userLabel"])
        return placeholder
    }

}
