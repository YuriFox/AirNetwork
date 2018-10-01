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
        var request = ANRequest(domain: self.domain, path: path, method: method)
        request.headerFields["User-Agent"] = String.headerFieldUserAgent
        request.headerFields["Accept-Language"] = Locale.current.languageCode
        request.headerFields[ANAuthorization.Key] = self.authorization?.description
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
        let dataTask = self.session.dataTask(with: request)
        self.debugLevel.printDescription(for: request)
        self.resumeTaskIfNeeded(dataTask)
        return dataTask
    }
    
    @discardableResult
    open func downloadTask(with request: ANRequest) -> ANDownloadTask {
        let downloadTask = self.session.downloadTask(with: request)
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
