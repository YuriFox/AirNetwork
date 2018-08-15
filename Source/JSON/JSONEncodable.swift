//
//  JSONMakeable.swift
//  AirNetwork
//
//  Created by Yuri Fox on 01.08.2018.
//  Copyright © 2018 Yuri Lysytsia. All rights reserved.
//

import Foundation

public protocol JSONEncodable {
    
    var json: JSON { get }
    
}

extension Int: JSONEncodable {
    public var json: JSON {
        return JSON(self)
    }
}
extension Float: JSONEncodable {
    public var json: JSON {
        return JSON(self)
    }
}
extension Double: JSONEncodable {
    public var json: JSON {
        return JSON(self)
    }
}
extension String: JSONEncodable {
    public var json: JSON {
        return JSON(self)
    }
}
extension Bool: JSONEncodable {
    public var json: JSON {
        return JSON(self)
    }
}
extension Array: JSONEncodable {
    public var json: JSON {
        return JSON(self)
    }
}
extension Dictionary: JSONEncodable {
    public var json: JSON {
        return JSON(self)
    }
}
extension URL: JSONEncodable {

    public var json: JSON {
        return JSON(self.absoluteString)
    }

}
