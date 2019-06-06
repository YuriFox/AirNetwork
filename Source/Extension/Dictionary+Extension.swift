//
//  Dictionary+Extension.swift
//  AirNetwork
//
//  Created by Yuri Fox on 02.08.2018.
//  Copyright © 2018 Yuri Lysytsia. All rights reserved.
//

import Foundation.NSData
import Foundation.NSDictionary

// MARK: - Query Items
extension Dictionary where Key == String, Value == Any {
    
    var queryItems: [URLQueryItem] {
        return self.queryComponents.map { URLQueryItem(name: $0, value: $1) }
    }
    
    var queryComponents: [(name: String, value: String)] {
        return self.reduce([(String, String)]()) { (result, dict) in
            return result + self.queryComponent(name: dict.key, value: dict.value)
        }
    }
    
    private func queryComponent(name: String, value: Any) -> [(String, String)] {
        var components = [(String, String)]()
        
        switch value {
        case let dictionary as [String : Any]:
            components = dictionary.reduce(into: components) { (result, dict) in
                result += self.queryComponent(name: "\(name)[\(dict.key)]", value: dict.value)
            }
            
        case let array as [Any]:
            components = array.reduce(into: components) { (result, array) in
                result += self.queryComponent(name: "\(name)[]", value: array)
            }
            
        case let number as NSNumber:
            components.append((name, number.isBool ? "\(number.boolValue)" : number.stringValue))
            
        case let string as String:
            components.append((name, string))
            
        default:
            components.append((name, String(describing: value)))
            
        }
        
        return components
    }
    
}

// MARK: - URL Encoding
extension Dictionary where Key == String, Value == Any {
    
    var urlEncodedString: String {
        return self.queryComponents.map { "\($0)=\($1)" }.joined(separator: "&")
    }
    
    func urlEncodedData(using encoding: String.Encoding, allowLossyConversion: Bool = false) -> Data? {
        return self.urlEncodedString.data(using: encoding, allowLossyConversion: allowLossyConversion)
    }
    
}

// MARK: - JSON
extension Dictionary where Key == String, Value == Any {
    
    var jsonData: Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
    }
    
}

// MARK: - Compacted
extension Dictionary where Value == Any? {
    
    public var compacted: [Key : Any] {
        var compactedItems: [Key : Any] = [:]
        self.forEach {
            guard let value = $0.value else { return }
            compactedItems[$0.key] = value
        }
        return compactedItems
    }
    
    public mutating func compact() {
        self = self.compacted
    }
    
}
