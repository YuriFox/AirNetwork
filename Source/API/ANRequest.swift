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
    
    /// The URL domain subcomponent.
    public var domain: String
    
    /// The URL path subcomponent.
    public var path: String
    
    /// An array of query items for the URL query string.
    public var queryItems: [String : Any] = [:]
    
    public var url: URL? {
        let queryItems: [URLQueryItem]? = {
            let items = self.queryItems.queryItems
            return items.isEmpty ? nil : items
        }()
        return URL(domain: self.domain, path: self.path, queryItems: queryItems)
    }
    
    /// The HTTP request method of the receiver.
    public var method: Method
    
    /// A dictionary containing all the HTTP header fields of the receiver.
    public var headerFields: [String : String] = [:]
    
    /// Data sent as the body of the request message. It is only supported for queries with POST, PUT, PATCH.
    public var body: Body?
    
    /// The timeout interval specifies the limit on the idle. Defaults to 60.0
    public var timeoutInterval: TimeInterval = 60
    
    /// Allowed the receiver to use the built in cellular radios to satisfy the request.
    public var allowsCellularAccess: Bool = true
    
    /// Should cookies will be sent with and set for this request.
    public var shouldHandleCookies: Bool = true
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.domain)
        hasher.combine(self.path)
        hasher.combine(self.timeoutInterval)
        hasher.combine(self.allowsCellularAccess)
        hasher.combine(self.shouldHandleCookies)
    }
    
    public var description: String {
        let method = self.method.rawValue
        let url = self.domain + self.path
        let hasHeader = !self.headerFields.isEmpty
        let hasBody = self.body != nil
        return "\(ANRequest.self): (\(method) \(url).\nHas header fields: \(hasHeader)\nHas body: \(hasBody))"
    }
    
    /// Creates request with the given path and method.
    /// - parameter path: The URL for the request.
    public init(domain: String, path: String, method: Method) {
        self.domain = domain
        self.path = path
        self.method = method
    }
    
    /// Creates GET request with url
    ///
    /// - Parameter url: The URL for the request.
    public init(url: URL) {
        self.init(domain: url.domain, path: url.path, method: .GET)
    }
    
    public static func == (lhs: ANRequest, rhs: ANRequest) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
}

// MARK: - Method
public extension ANRequest {
    
    public enum Method: String {
        
        case GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, OPTIONS
        
        public var supportsBody: Bool {
            switch self {
            case .POST, .PUT, .PATCH: return true
            case .GET, .HEAD, .DELETE, .TRACE, .OPTIONS: return false
            }
        }
        
    }
    
}

// MARK: - ContentType
public extension ANRequest {
    
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
public extension ANRequest {
    
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

// MARK: - URL+Extesnion
extension URL {
    
    fileprivate init?(domain: String, path: String? = nil, queryItems: [URLQueryItem]? = nil) {
        
        guard var components = URLComponents(string: domain) else { return nil }
        
        if let path = path {
            components.path = path
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else { return nil }
        self = url

    }
    
    fileprivate init?(url: URL, queryItems: [URLQueryItem]? = nil) {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return nil }
        components.queryItems = queryItems
        guard let link = components.string else { return nil }
        self.init(string: link)
    }
    
}


// MARK: - URLRequest+Extension
extension URLRequest {
    
    init?(request: ANRequest) {
        guard let url = request.url else { return nil }
        
        self.init(url: url, timeoutInterval: request.timeoutInterval)
        self.allowsCellularAccess = request.allowsCellularAccess
        self.httpShouldHandleCookies = request.shouldHandleCookies
        
        self.httpMethod = request.method.rawValue
        
        request.headerFields.forEach {
            self.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        
        guard let body = request.body else { return }
        
        switch body.contentType {
        case .text:
            let text = String(describing: body.items.json.object)
            self.setValue(body.contentType.rawValue, forHTTPHeaderField: ANRequest.ContentType.key)
            self.httpBody = text.data(using: .utf8)
            
        case .json:
            self.setValue(body.contentType.rawValue, forHTTPHeaderField: ANRequest.ContentType.key)
            self.httpBody = body.items.json.jsonData(options: .prettyPrinted)
            
        case .urlEncoded:
            self.setValue(body.contentType.rawValue, forHTTPHeaderField: ANRequest.ContentType.key)
            self.httpBody = body.items.json.urlEncodedData
            
        case .multipart:
            
            let boundary = "Boundary-\(UUID().uuidString)"
            let contentTypeValue = "\(body.contentType.rawValue); boundary=\(boundary)"
            self.setValue(contentTypeValue, forHTTPHeaderField: ANRequest.ContentType.key)
            self.httpBody = body.items.json.multipartData(boundary: boundary)
            
        }
        
    }
    
}

fileprivate extension URL {
    
    var domain: String {
        return self.absoluteString.replacingOccurrences(of: self.path, with: "")
    }
    
}
