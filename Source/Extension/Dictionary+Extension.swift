//
//  Dictionary+Extension.swift
//  AirNetwork
//
//  Created by Yuri Fox on 02.08.2018.
//  Copyright © 2018 Yuri Lysytsia. All rights reserved.
//

import Foundation.NSData
import Foundation.NSDictionary

// MARK: - URL Encoded
extension Dictionary where Key == String, Value == Any {
    
    var urlEncodedData: Data? {
        return self.urlEncodedString.data(using: .utf8)
    }
    
    var urlEncodedString: String {
        
        var components: [(String, String)] = []
        
        for (key, value) in self {
            components += self.urlEncodedComponents(key: key, value: value)
        }
        
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
        
    }
    
    func urlEncodedComponents(key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []
        
        switch value {
        case let dictionary as [String : Any]:
            for (dictionaryKey, dictionaryValue) in dictionary {
                components += self.urlEncodedComponents(key: "\(key)[\(dictionaryKey)]", value: dictionaryValue)
            }
            
        case let array as [Any]:
            for arrayValue in array {
                components += self.urlEncodedComponents(key: "\(key)[]", value: arrayValue)
            }
            
        case let number as NSNumber:
            if number.isBool {
                components.append((key.urlEncodedString, "\(number.boolValue)".urlEncodedString))
            } else {
                components.append((key.urlEncodedString, "\(number)".urlEncodedString))
            }
            
        case let string as String:
            components.append((key.urlEncodedString, string.urlEncodedString))
            
        case let bool as Bool:
            components.append((key.urlEncodedString, "\(bool.hashValue)".urlEncodedString))
            
        default:
            components.append((key.urlEncodedString, String(describing: value)))
            
        }
        
        return components
    }
    
    var queryItems: [URLQueryItem] {
        var components: [(String, String)] = []
        
        for (key, value) in self {
            components += self.urlEncodedComponents(key: key, value: value)
        }
        
        return components.map { URLQueryItem(name: $0, value: $1) }
    }
    
}

// MARK: - URL Encoded (String)
fileprivate extension String {
    
    var urlEncodedString: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
    
}


// MARK: - JSON
extension Dictionary where Key == String, Value == Any {
    
    var jsonData: Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: [])
    }
    
}
