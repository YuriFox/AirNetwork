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
        return URL(domain: self.domain, path: self.path, queryItems: queryItems.queryItems)
    }
    
    /// The HTTP request method of the receiver.
    public var method: Method
    
    /// A dictionary containing all the HTTP header fields of the receiver.
    public var headerFields: [String : String] = [:]
    
    /// This data is sent as the message body of the request.
    public var body: Body?
    
    /// The timeout interval specifies the limit on the idle. Defaults to 60.0
    public var timeoutInterval: TimeInterval = 60
    
    /// Allowed the receiver to use the built in cellular radios to satisfy the request.
    public var allowsCellularAccess: Bool = true
    
    /// Should cookies will be sent with and set for this request.
    public var shouldHandleCookies: Bool = true
    
    public var hashValue: Int {
        return self.domain.hashValue ^ self.path.hashValue ^ timeoutInterval.hashValue ^ allowsCellularAccess.hashValue ^ self.shouldHandleCookies.hashValue
    }
    
    public var description: String {
        let method = self.method.rawValue
        let url = self.domain + self.path
        let hasHeader = !self.headerFields.isEmpty
        let hasBody = self.body != nil
        return "\(ANRequest.self): (\(method) \(url).\nHas header fields: \(hasHeader)\nHas body: \(hasBody))"
    }
    
    /// Creates request with the given path and method.
    /// - parameter: path The URL for the request.
    public init(domain: String, path: String, method: Method) {
        self.domain = domain
        self.path = path
        self.method = method
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
        public var items: Any
        
        public init(contentType: ContentType, items: Any = NSNull()) {
            self.contentType = contentType
            self.items = items
        }
        
    }
    
}

// MARK: - MultipartFile
public extension ANRequest {
    
    public struct MultipartFile {
        
        public private(set) var name: String
        public private(set) var data: Data
        public private(set) var mimeType: String
        public var bodyItems: [String : Any] = [:]
        
        private init(name: String, data: Data, mimeType: String) {
            self.name = name
            self.data = data
            self.mimeType = mimeType
        }
        
        private static var uniqueName: String {
            return UUID().uuidString
        }
        
        public init?(text: String, name: String? = nil) {
            guard let data = text.data(using: .utf8) else { return nil }
            let name = name ?? MultipartFile.uniqueName
            self.init(name: name, data: data, mimeType: "text/plain")
        }
        
        public init?(json: [String : Any], name: String? = nil) {
            guard let data = json.jsonData else { return nil }
            let name = name ?? MultipartFile.uniqueName
            self.init(name: name, data: data, mimeType: "application/json")
        }
        
        public init?(imageJPEG: UIImage, quality: CGFloat = 1, name: String? = nil) {
            guard let data = UIImageJPEGRepresentation(imageJPEG, quality) else { return nil }
            let name = "\(name ?? MultipartFile.uniqueName).jpeg"
            self.init(name: name, data: data, mimeType: "image/jpeg")
        }
        
        public init?(imagePNG: UIImage, name: String? = nil) {
            guard let data = UIImagePNGRepresentation(imagePNG) else { return nil }
            let name = "\(name ?? MultipartFile.uniqueName).png"
            self.init(name: name, data: data, mimeType: "image/png")
        }
        
        public init?(videoMOV url: URL, name: String? = nil) {
            guard let data = try? Data(contentsOf: url, options: []) else { return nil }
            let name = "\(name ?? MultipartFile.uniqueName).mov"
            self.init(name: name, data: data, mimeType: "video/mov")
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
        // TODO
        guard let link = components.string else { return nil }
        self.init(string: link)
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
            let text = String.init(describing: body.items)
            self.setValue(body.contentType.rawValue, forHTTPHeaderField: ANRequest.ContentType.key)
            self.httpBody = text.data(using: .utf8)
        case .json:
            guard let items = body.items as? [String : Any] else {
                fatalError("\(#file) \(#function) json content type has to use 'bodyItems' is '[String : Any]'")
            }
            self.setValue(body.contentType.rawValue, forHTTPHeaderField: ANRequest.ContentType.key)
            self.httpBody = items.jsonData
            
        case .urlEncoded:
            guard let items = body.items as? [String : Any] else {
                fatalError("\(#file) \(#function) urlEncoded content type has to use 'bodyItems' is '[String : Any]'")
            }
            self.setValue(body.contentType.rawValue, forHTTPHeaderField: ANRequest.ContentType.key)
            self.httpBody = items.urlEncodedData
            
        case .multipart:
            
            let boundary = "Boundary-\(UUID().uuidString)"
            let contentTypeValue = "\(body.contentType.rawValue); boundary=\(boundary)"
            self.setValue(contentTypeValue, forHTTPHeaderField: ANRequest.ContentType.key)
            
            var bodyData = Data()
            
            if let items = body.items as? [String : ANRequest.MultipartFile] {
                
                items.forEach { (key, file) in
                    bodyData.append(multipartFile: file, forKey: key, boundary: boundary)
                }
                
            } else if let items = body.items as? [String : [ANRequest.MultipartFile]] {
                
                items.forEach { (key, files) in
                    files.forEach { (file) in
                        bodyData.append(multipartFile: file, forKey: key, boundary: boundary)
                    }
                }
                
            } else {
                fatalError("\(#file) \(#function) multipart content type has to use 'bodyItems' is '[String : YFMultipartFile]' or '[String : [YFMultipartFile]]'")
            }
            
            bodyData.append(string: "--\(boundary)--\r\n")
            self.httpBody = bodyData
            
        }
        
    }
    
}
