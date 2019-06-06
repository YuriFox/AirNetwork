//
//  ANAuthorization.swift
//  AirNetwork
//
//  Created by Yuri Fox on 02.08.2018.
//  Copyright © 2018 Yuri Lysytsia. All rights reserved.
//

import Foundation

public struct ANAuthorization: Hashable, CustomStringConvertible {
    
    public let type: ANAuthorizationType
    public var token: String
    
    public static var Key: String {
        return "Authorization"
    }
    
    public var description: String {
        return "\(self.type.description) \(self.token)"
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.description)
    }
    
    public init(type: ANAuthorizationType, token: String) {
        self.type = type
        self.token = token
    }
    
    public init?(string: String) {
        let strings = string.components(separatedBy: " ")
        
        guard
            strings.indices.contains(0) && strings.indices.contains(1),
            let type = ANAuthorizationType(rawValue: strings[0])
        else { return nil }
        
        self.type = type
        self.token = strings[1]
        
    }
    
}

public enum ANAuthorizationType: String, CustomStringConvertible {
    
    case basic, bearer
    
    public var description: String {
        return self.rawValue.capitalized
    }
    
}
