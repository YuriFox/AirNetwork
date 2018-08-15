//
//  JSONMapable.swift
//  AirNetwork
//
//  Created by Yuri Lysytsia on 01.08.2018.
//  Copyright © 2018 Yuri Lysytsia. All rights reserved.
//

import Foundation

public protocol JSONDecodable {
    init?(json: JSON)
}

public protocol JSONDefaultDecodable: JSONDecodable {
    static var defaultValue: Self { get }
}

prefix operator ~
prefix operator ≈

public prefix func ~ <T: JSONDecodable>(rhs: JSON) -> T? {
    return T(json: rhs)
}

public prefix func ≈ <T: JSONDefaultDecodable>(rhs: JSON) -> T {
    return T(json: rhs) ?? T.defaultValue
}

extension Int: JSONDefaultDecodable {
    
    public init?(json: JSON) {
        guard let int = json.int else { return nil }
        self = int
    }
    
    public static var defaultValue: Int { return 0 }
}

extension Float: JSONDefaultDecodable {
    
    public init?(json: JSON) {
        guard let float = json.float else { return nil }
        self = float
    }
    
    public static var defaultValue: Float { return 0 }
}

extension Double: JSONDefaultDecodable {
    
    public init?(json: JSON) {
        guard let double = json.double else { return nil }
        self = double
    }
    
    public static var defaultValue: Double { return 0 }
    
}

extension String: JSONDefaultDecodable {
    
    public init?(json: JSON) {
        guard let string = json.string else { return nil }
        self = string
    }
    
    public static var defaultValue: String { return "" }
    
}

extension Bool: JSONDefaultDecodable {
    
    public init?(json: JSON) {
        guard let bool = json.bool else { return nil }
        self = bool
    }
    
    public static var defaultValue: Bool { return false }
    
}

extension Array: JSONDefaultDecodable {

    public init?(json: JSON) {
        guard let array = json.arrayObject else { return nil }
        self = array as! [Element]
    }
    
    public static var defaultValue: Array { return [] }
    
}

extension Dictionary: JSONDefaultDecodable {
    
    public init?(json: JSON) {
        guard let dictionary = json.dictionaryObject else { return nil }
        self = dictionary as! [Key: Value]
    }
    
    public static var defaultValue: Dictionary { return [:] }
    
}

extension URL: JSONDecodable {
    
    public init?(json: JSON) {
        guard let url = URL(string: json.stringValue) else { return nil }
        self = url
    }
    
}
