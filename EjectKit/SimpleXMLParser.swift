//
//  SimpleXMLParser.swift
//  Eject
//
//  Created by Brian King on 11/7/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation
// The XML parser in Foundation is broken on Linux, so parse by hand. This only supports
// a very limited version of the XML spec.

public enum SAXEvent {
    case enter(elementName: String, attributes: [String: String])
    case body(string: String)
    case comment(string: String)
    case exit(elementName: String)
}

extension SAXEvent: Equatable {

    public static func ==(lhs: SAXEvent, rhs: SAXEvent) -> Bool {
        switch (lhs, rhs) {
        case let (.enter(lhsElementName, lhsAttributes), .enter(rhsElementName, rhsAtributes)):
            return lhsElementName == rhsElementName && lhsAttributes == rhsAtributes
        case let (.body(lhsString), .body(rhsString)):
            return lhsString == rhsString
        case let (.comment(lhsComment), .comment(rhsComment)):
            return lhsComment == rhsComment
        case let (.exit(lhsElementName), .exit(rhsElementName)):
            return lhsElementName == rhsElementName
        default:
            return false
        }
    }

}

public struct SimpleXMLParser {
    public static func parse(string: String, handler: (SAXEvent) -> Void) throws {
        return try string.utf8CString.withUnsafeBufferPointer { nulTerminatedBuffer in
            return try nulTerminatedBuffer.baseAddress!.withMemoryRebound(to: UInt8.self, capacity: nulTerminatedBuffer.count) { (utf8Base) throws in
                // don't want to include the nul termination in the buffer - trim it off
                let buffer = UnsafeBufferPointer(start: utf8Base, count: nulTerminatedBuffer.count - 1)
                var parser = SimpleXMLParser(input: buffer)
                return try parser.parse(handler: handler)
            }
        }
    }
    enum Constants {
        static let COMMENT_PREFIX = [Constants.LT, Constants.BANG, Constants.MINUS, Constants.MINUS]
        static let COMMENT_SUFFIX = [Constants.MINUS, Constants.MINUS, Constants.GT]
        static let BACKSLASH = UInt8(ascii: "\\")
        static let GT        = UInt8(ascii: ">")
        static let LT        = UInt8(ascii: "<")
        static let EQ        = UInt8(ascii: "=")
        static let SLASH     = UInt8(ascii: "/")
        static let MINUS     = UInt8(ascii: "-")
        static let BANG      = UInt8(ascii: "!")
        static let SPACE     = UInt8(ascii: " ")
        static let QUOTE     = UInt8(ascii: "'")
        static let DOUBLEQUOTE = UInt8(ascii: "\"")
        static let QUESTION  = UInt8(ascii: "?")

        static let uppercase = UInt8(ascii: "A")...UInt8(ascii: "Z")
        static let lowercase = UInt8(ascii: "a")...UInt8(ascii: "z")
        static let numeric   = UInt8(ascii: "0")...UInt8(ascii: "9")
    }

    enum Error: Swift.Error {
        case missingLT
        case missingGT
        case missingGTAfterSlash
        case missingElement
        case missingAttribute
        case missingEqual
        case missingAttributeValue
        case unsupportedEncoding
    }

    let input: UnsafeBufferPointer<UInt8>
    var location = 0
    var depth = 0

    init(input: UnsafeBufferPointer<UInt8>) {
        self.input = input
    }

    @inline(__always) mutating func next() {
        location += 1
    }

    @inline(__always) func peek(shift: Int = 0) -> UInt8? {
        guard location + shift < input.count else {
            return nil
        }
        return input[location + shift]
    }

    @inline(__always) func check(sequence: [UInt8]) -> Bool {
        for (index, item) in sequence.enumerated() {
            if peek(shift: index) != item {
                return false
            }
        }
        return true
    }

    @inline(__always) func contains(utf8: UInt8?, ranges: [CountableClosedRange<UInt8>]) -> Bool {
        guard let utf8 = utf8 else { return false }
        let count = ranges.count
        if count > 0 && ranges[0].contains(utf8) {
            return true
        }
        if count > 1 && ranges[1].contains(utf8) {
            return true
        }
        if count > 2 && ranges[2].contains(utf8) {
            return true
        }
        return false
    }

    @inline(__always) func eof() -> Bool {
        return location >= input.count
    }

    func string(from: Int) -> String? {
        guard from != location else { return nil }
        let start = input.baseAddress?.advanced(by: from)
        let string = String(bytesNoCopy: UnsafeMutableRawPointer(mutating: start!), length: location - from, encoding: String.Encoding.utf8, freeWhenDone: false)
        return string
    }

    mutating func scan(character: UInt8) -> Bool {
        let found = (peek() == character)
        if found {
            next()
        }
        return found
    }

    mutating func discardWhitespace() {
        while peek() == Constants.SPACE { next() }
    }

    mutating func scan(untilUnescaped: UInt8) -> String? {
        let start = location
        escaped: while !eof() {
            if peek() == Constants.BACKSLASH {
                next()
                break escaped
            }
            else if untilUnescaped != peek() {
                next()
            }
            else {
                break
            }
        }
        return string(from: start)
    }

    mutating func scanQuote() -> String? {
        guard let peek = peek() else {
            return nil
        }
        var quote: String? = nil
        if peek == Constants.QUOTE || peek == Constants.DOUBLEQUOTE {
            next()
            quote = scan(untilUnescaped: peek) ?? ""
            next()
        }
        if quote == nil {
            print("hi")
        }
        return quote
    }

    mutating func scanToken() -> String? {
        // First character must be a-Z
        guard contains(utf8: peek(), ranges: [Constants.uppercase, Constants.lowercase]) else {
            return nil
        }
        let start = location
        next()
        // Remaining can be a-z0-9
        while contains(utf8: peek(), ranges: [Constants.uppercase, Constants.lowercase, Constants.numeric]) {
            next()
        }
        return string(from: start)
    }

    mutating func scanComment() -> String? {
        guard check(sequence: Constants.COMMENT_PREFIX) else {
            return nil
        }
        location += Constants.COMMENT_PREFIX.count

        let start = location
        while !(check(sequence: Constants.COMMENT_SUFFIX)) && !eof() {
            next()
        }
        if eof() {
            return nil
        }
        let comment = string(from: start)
        location += Constants.COMMENT_SUFFIX.count
        return comment
    }

    mutating func parseProlog() throws {
        guard scan(character: Constants.LT)         else { throw Error.missingLT }
        discardWhitespace()
        guard scan(character: Constants.QUESTION)   else { throw Error.missingLT }
        discardWhitespace()
        guard scanToken() != nil                    else { throw Error.missingElement }
        discardWhitespace()
        var attributes: [String: String] = [:]
        while peek() != Constants.QUESTION {
            guard let attribute = scanToken()       else { throw Error.missingAttribute }
            discardWhitespace()
            guard scan(character: Constants.EQ)     else { throw Error.missingEqual }
            discardWhitespace()
            guard let value = scanQuote()           else { throw Error.missingAttributeValue }
            discardWhitespace()
            attributes[attribute] = value
        }
        guard scan(character: Constants.QUESTION)   else { throw Error.missingLT }
        discardWhitespace()
        guard scan(character: Constants.GT)         else { throw Error.missingLT }
    }

    mutating func parseElement(handler: (SAXEvent) -> Void) throws {
        discardWhitespace()
        if let comment = scanComment() {
            handler(.comment(string: comment))
            discardWhitespace()
            return
        }
        guard scan(character: Constants.LT)         else { throw Error.missingLT }
        discardWhitespace()
        guard let element = scanToken()             else { throw Error.missingElement }
        discardWhitespace()
        var attributes: [String: String] = [:]
        while peek() != Constants.GT && peek() != Constants.SLASH {
            guard let attribute = scanToken()       else { throw Error.missingAttribute }
            discardWhitespace()
            guard scan(character: Constants.EQ)     else { throw Error.missingEqual }
            discardWhitespace()
            guard let value = scanQuote()           else { throw Error.missingAttributeValue }
            discardWhitespace()
            attributes[attribute] = value
        }
        if scan(character: Constants.SLASH) {
            guard scan(character: Constants.GT)     else { throw Error.missingGTAfterSlash }
            handler(.enter(elementName: element, attributes: attributes))
            handler(.exit(elementName: element))
        }
        else {
            guard scan(character: Constants.GT)     else { throw Error.missingGT }
            handler(.enter(elementName: element, attributes: attributes))
            depth += 1
            try parse(handler: handler)
            guard scan(character: Constants.LT)     else { throw Error.missingLT }
            guard scan(character: Constants.SLASH)  else { throw Error.missingLT }
            discardWhitespace()
            guard let element = scanToken()         else { throw Error.missingElement }
            discardWhitespace()
            guard scan(character: Constants.GT)     else { throw Error.missingGT }
            handler(.exit(elementName: element))
            depth -= 1
        }
    }

    mutating func parse(handler: (SAXEvent) -> Void) throws {
        if peek() == Constants.LT && peek(shift: 1) == Constants.QUESTION {
            try parseProlog()
        }
        while !eof() {
            if let body = scan(untilUnescaped: Constants.LT) { handler(.body(string: body)) }
            if peek() == Constants.LT && peek(shift: 1) == Constants.SLASH {
                break
            }
            else {
                try parseElement(handler: handler)
                if let body = scan(untilUnescaped: Constants.LT) { handler(.body(string: body)) }
            }
        }
    }

}
