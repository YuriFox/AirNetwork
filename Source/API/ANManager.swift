//
//  ANManager.swift
//  AirNetwork
//
//  Created by Yuri Fox on 02.08.2018.
//  Copyright © 2018 Yuri Lysytsia. All rights reserved.
//

import Foundation
import UIKit.UIApplication

open class ANManager: NSObject {
    
    /// Default request domain.
    public let domain: String
    
    /// Default session for tasks.
    public let session: ANSession
    
    /// Authorization header for all requests.
    public var authorization: ANAuthorization?
    
    /// Resumes the task immediately.
    public var startRequestsImmediately: Bool = true
    
    /// Logs for all request.
    public var debugLevel: ANDebugLevel = .none
    
    internal var networkActivitiesCount: Int = 0
    
    /// Create manager with domain.
    public init(session: ANSession, domain: String) {
        self.session = session
        self.domain = domain
    }
    
    open func request(path: String, method: ANRequest.Method) -> ANRequest {
        var request = ANRequest(path: path, method: method)
        
        var headers = [String : String]()
        headers["User-Agent"] = String.headerFieldUserAgent
        headers["Accept-Language"] = Locale.current.languageCode
        headers[ANAuthorization.Key] = self.authorization?.description
        request.headerFields = headers
        
        return request
    }

    private func resumeTaskIfNeeded(_ task: ANTask) {
        self.startNetworkActivity()
        if self.startRequestsImmediately {
            task.resume()
        }
    }
    
    @discardableResult
    open func dataTask(with request: ANRequest) -> ANDataTask {
        let urlRequest = self.request(request)
        let dataTask = self.session.dataTask(with: urlRequest)
        self.debugLevel.printDescription(for: request)
        self.resumeTaskIfNeeded(dataTask)
        return dataTask
    }
    
    @discardableResult
    open func downloadTask(with request: ANRequest) -> ANDownloadTask {
        let urlRequest = self.request(request)
        let downloadTask = self.session.downloadTask(with: urlRequest)
        self.debugLevel.printDescription(for: request)
        self.resumeTaskIfNeeded(downloadTask)
        return downloadTask
    }
    
}

// MARK: - Network Activity
extension ANManager {
    
    internal func startNetworkActivity() {
        self.networkActivitiesCount += 1
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }
    
    internal func stopNetworkActivity() {
        if self.networkActivitiesCount < 1 {
            return
        }
        
        self.networkActivitiesCount -= 1
        
        if networkActivitiesCount == 0 {
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
        
    }
    
}

// MARK: - String + Extension
internal extension String {
    
    static var headerFieldUserAgent: String {
        let title = String(describing: ANManager.self)
        
        guard let info = Bundle.main.infoDictionary else {
            return title
        }
        
        let executable = info[kCFBundleExecutableKey as String] as? String ?? "Unknown"
        let appVersion = info["CFBundleShortVersionString"] as? String ?? "Unknown"
        let bundle = info[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
        let appBuild = info[kCFBundleVersionKey as String] as? String ?? "Unknown"
        
        let osNameVersion: String = {
            let version = ProcessInfo.processInfo.operatingSystemVersion
            let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
            
            let osName: String = {
                #if os(iOS)
                return "iOS"
                #elseif os(watchOS)
                return "watchOS"
                #elseif os(tvOS)
                return "tvOS"
                #elseif os(macOS)
                return "OS X"
                #elseif os(Linux)
                return "Linux"
                #else
                return "Unknown"
                #endif
            }()
            
            return "\(osName) \(versionString)"
        }()
        
        let senderVersion: String = {
            let senderInfo = Bundle(for: ANManager.self).infoDictionary
            guard let build = senderInfo?["CFBundleShortVersionString"] as? String else {
                return title
            }
            
            return "\(title)/\(build)"
        }()
        
        return "\(executable)/\(appVersion) (\(bundle); build:\(appBuild); \(osNameVersion)) \(senderVersion)"
        
    }
    
}

// MARK: - Request
extension ANManager {
    
    private func url(path: String, queryItems: [String : Any]?) -> URL? {
        guard var urlComponents = URLComponents(string: self.domain) else {
            fatalError("ANManager.URLComponents can't initialize because domain(\(self.domain)) isn't valid")
        }
        urlComponents.path = path
        urlComponents.queryItems = queryItems?.queryItems
        return urlComponents.url
    }
    
    
    private func request(_ request: ANRequest) -> URLRequest {
        guard let url = self.url(path: request.path, queryItems: request.queryItems) else {
            fatalError("ANManager.URLRequest can't initialize url for  domain(\(self.domain)) path(\(request.path))")
        }
        
        var urlRequest = URLRequest(url: url, timeoutInterval: request.timeoutInterval)
        urlRequest.allowsCellularAccess = request.allowsCellularAccess
        urlRequest.httpShouldHandleCookies = request.shouldHandleCookies
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headerFields
        
        guard let body = request.body else { return urlRequest }
        
        if !request.method.supportsBody {
            debugPrint("ANManager.URLRequest can't add body because method(\(request.method.rawValue) doesn't support body)")
            return urlRequest
        }
        
        switch body.contentType {
        case .text:
            let text = String(describing: body.items.json.object)
            urlRequest.setValue(body.contentType.rawValue, forHTTPHeaderField: ANRequest.ContentType.key)
            urlRequest.httpBody = text.data(using: .utf8)
            
        case .json:
            urlRequest.setValue(body.contentType.rawValue, forHTTPHeaderField: ANRequest.ContentType.key)
            urlRequest.httpBody = body.items.json.jsonData(options: .prettyPrinted)
            
        case .urlEncoded:
            urlRequest.setValue(body.contentType.rawValue, forHTTPHeaderField: ANRequest.ContentType.key)
            urlRequest.httpBody = body.items.json.urlEncodedData
            
        case .multipart:
            let boundary = "Boundary-\(UUID().uuidString)"
            let contentTypeValue = "\(body.contentType.rawValue); boundary=\(boundary)"
            urlRequest.setValue(contentTypeValue, forHTTPHeaderField: ANRequest.ContentType.key)
            urlRequest.httpBody = body.items.json.multipartData(boundary: boundary)
        }
        
        return urlRequest
        
    }
    
}
