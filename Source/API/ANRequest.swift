//
//  ANRequest.swift
//  AirNetwork
//
//  Created by Yuri Fox on 02.08.2018.
//  Copyright © 2018 Yuri Lysytsia. All rights reserved.
//

import Foundation
import UIKit.UIImage
import struct UIKit.CGFloat

public struct ANRequest: Hashable, CustomStringConvertible {
    
    /// The HTTP request method of the receiver.
    public var method: Method
    
    /// The URL path subcomponent.
    public var path: String
    
    /// An array of query items for the URL query string.
    public var queryItems: [String : Any]?
    
    /// A dictionary containing all the HTTP header fields of the receiver.
    public var headerFields: [String : String]?
    
    /// Data sent as the body of the request message. It is only supported for queries with POST, PUT, PATCH.
    public var body: Body?
    
    /// The timeout interval specifies the limit on the idle. Defaults to 60.0
    public var timeoutInterval: TimeInterval = 60
    
    /// Allowed the receiver to use the built in cellular radios to satisfy the request.
    public var allowsCellularAccess: Bool = true
    
    /// Should cookies will be sent with and set for this request.
    public var shouldHandleCookies: Bool = true
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.path)
        hasher.combine(self.timeoutInterval)
        hasher.combine(self.allowsCellularAccess)
        hasher.combine(self.shouldHandleCookies)
    }
    
    public var description: String {
        let method = self.method.rawValue
        let url = self.path
        let hasHeader = self.headerFields?.isEmpty == false
        let hasBody = self.body != nil
        return "\(ANRequest.self): (\(method) \(url).\nHas header fields: \(hasHeader)\nHas body: \(hasBody))"
    }
    
    /// Creates request with the given path and method.
    /// - parameter path: The URL for the request.
    public init(path: String, method: Method) {
        self.path = path
        self.method = method
    }
    
    public static func == (lhs: ANRequest, rhs: ANRequest) -> Bool {
        return lhs.description == rhs.description
    }
    
}

// MARK: - Method
extension ANRequest {
    
    public enum Method: RawRepresentable {
        
        case get, head, post, put, patch, delete, trace, options, custom(String)
        
        public var rawValue: String {
            switch self {
            case .get: return "GET"
            case .head: return "HEAD"
            case .post: return "POST"
            case .put: return "PUT"
            case .patch: return "PATCH"
            case .delete: return "DELETE"
            case .trace: return "TRACE"
            case .options: return "OPTIONS"
            case let .custom(value): return value.uppercased()
            }
        }
        
        public var supportsBody: Bool {
            switch self {
            case .post, .put, .patch: return true
            default: return false
            }
        }
        
        public init(rawValue: String) {
            let value = rawValue.lowercased()
            switch value {
            case "get": self = .get
            case "head": self = .head
            case "post": self = .post
            case "put": self = .put
            case "patch": self = .patch
            case "delete": self = .delete
            case "trace": self = .trace
            case "options": self = .options
            default: self = .custom(value)
            }
        }
        
        public typealias RawValue = String
        
    }
    
}

// MARK: - ContentType
extension ANRequest {
    
    public enum ContentType: String {
        
        case text = "text/plain"
        case json = "application/json"
        case urlEncoded = "application/x-www-form-urlencoded"
        case multipart = "multipart/form-data"
        
        public static var key: String {
            return "Content-Type"
        }
        
    }
    
}

// MARK: - Body
extension ANRequest {
    
    public struct Body {
        
        public private(set) var contentType: ContentType
        public var items: JSONEncodable
        
        /// The data sent as the message body of the request.
        ///
        /// - Parameters:
        ///   - contentType: Data type for request body
        ///   - items: Data for request body.
        /// - Note: Depending on the contentType, it is recommended to use data with types:
        /// - text: String, Number or Bool.
        /// - json: [String : Any] or [Any].
        /// - urlEncoded: the same as json.
        /// - multipart: [String: Any] or [String : ANMultipartFile]
        public init(contentType: ContentType, items: JSONEncodable) {
            self.contentType = contentType
            self.items = items
        }
        
    }
    
}
