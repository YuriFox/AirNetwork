//
//  JSONMapable.swift
//  AirNetwork
//
//  Created by Yuri Lysytsia on 01.08.2018.
//  Copyright © 2018 Yuri Lysytsia. All rights reserved.
//

// typealias JSONCodable = JSONDecodable & JSONEncodable

import Foundation

infix operator <<<

public protocol JSONDecodable {
    
    init?(json: JSON)
    
}

public func <<< <T: JSONDecodable>(lhs: inout T, rhs: JSON) {
    guard let newValue = T.init(json: rhs) else {
        assert(true, "Can't init object with json")
        return
    }
    
    lhs = newValue
}

public func <<< <T: JSONDecodable>(lhs: inout T?, rhs: JSON) {
    lhs = T.init(json: rhs)
}

extension Int: JSONDecodable {
    
    public init?(json: JSON) {
        guard let int = json.int else { return nil }
        self = int
    }
    
}

extension Float: JSONDecodable {
    
    public init?(json: JSON) {
        guard let float = json.float else { return nil }
        self = float
    }
    
}

extension Double: JSONDecodable {
    
    public init?(json: JSON) {
        guard let double = json.double else { return nil }
        self = double
    }
    
}

extension String: JSONDecodable {
    
    public init?(json: JSON) {
        guard let string = json.string else { return nil }
        self = string
    }
    
}

extension Bool: JSONDecodable {
    
    public init?(json: JSON) {
        guard let bool = json.bool else { return nil }
        self = bool
    }
    
}

extension Array: JSONDecodable where Element: JSONDecodable {
    
    public init?(json: JSON) {
        guard let array = json.arrayObject else { return nil }
        self = array as! [Element]
    }
    
}

extension Dictionary: JSONDecodable {
    
    public init?(json: JSON) {
        guard let dictionary = json.dictionary else { return nil }
        self = dictionary as! [Key: Value]
    }
    
}

extension URL: JSONDecodable {
    
    public init?(json: JSON) {
        guard let url = URL(string: json.stringValue) else { return nil }
        self = url
    }
    
}
