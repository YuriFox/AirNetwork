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
    
    /// Default request domain
    public let domain: String
    
    /// Authorization header for all requests
    public var authorization: ANAuthorization? {
        set {
            self.session.configuration.httpAdditionalHeaders?[ANAuthorization.Key] = newValue?.description
        }
        get {
            let headers = self.session.configuration.httpAdditionalHeaders
            guard let a = headers?[ANAuthorization.Key] as? String else { return nil }
            return ANAuthorization(string: a)
        }
    }
    
    /// Resumes the task immediately
    public var startRequestsImmediately: Bool = true
    
    /// Logs for all request
    public var debugLevel: ANDebugLevel = .none
    
    /// URLSession for data task
    public private(set) lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders?["User-Agent"] = String.headerFieldUserAgent
        configuration.httpAdditionalHeaders?["Accept-Language"] = Locale.current.languageCode
        return URLSession(configuration: configuration, delegate: self, delegateQueue: .main)
    }()
    
    internal var tasks: Set<ANTask> = []
    internal var networkActivitiesCount: Int = 0
    
    /// Create manager with domain
    public init(domain: String) {
        self.domain = domain
    }
    
    open func request(path: String, method: ANRequest.Method) -> ANRequest {
        return ANRequest(domain: self.domain, path: path, method: method)
//
//
//        if let authorization = self.authorization {
//            request.headerFields[ANAuthorization.Key] = authorization.description
//        }
//
//        return request        
    }
    
    @discardableResult
    open func dataTask(with request: ANRequest) -> ANTask {
        guard let urlRequest = URLRequest(request: request) else {
            fatalError("\(self) \(#function) \(#line) invalid YFNetworkRequest")
        }
        
        self.debugLevel.printDescription(for: request)
        
        self.startNetworkActivity()
        let dataTask = self.session.dataTask(with: urlRequest)
        let task = ANTask(task: dataTask)
        self.tasks.insert(task)
        
        if self.startRequestsImmediately {
            task.resume()
        }
        
        return task
        
    }
    
    private func task(_ dataTask: URLSessionTask) -> ANTask? {
        return self.tasks.first { $0.task == dataTask }
    }
    
    private func releaseTask(_ task: ANTask) {
        self.tasks.remove(task)
    }
    
    deinit {
        print("\(self) deinited")
    }
    
}

// MARK: - URLSessionTaskDelegate
extension ANManager: URLSessionDataDelegate {
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        guard let task = self.task(dataTask) else { return }
        
        if task.data != nil {
            task.data?.append(data)
        } else {
            task.data = data
        }
        
        task.progressHandler?(task.progress)
        
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        guard let task = self.task(task) else { return }
        self.debugLevel.printDescription(for: task)
    
        if let data = task.data, let response = task.response {
            task.completionHandler?(.success((data, response)))
        } else if let response = task.response {
            task.completionHandler?(.success((nil, response)))
        } else if let error = error {
            task.completionHandler?(.error(error))
        }
        
        self.releaseTask(task)
        self.stopNetworkActivity()
        
    }
    
}

// MARK: - Network Activity
extension ANManager {
    
    func startNetworkActivity() {
        self.networkActivitiesCount += 1
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }
    
    func stopNetworkActivity() {
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
fileprivate extension String {
    
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
