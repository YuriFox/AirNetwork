//
//  ANSession.swift
//  AirNetwork
//
//  Created by Yuri Fox on 10/1/18.
//  Copyright © 2018 Yuri Lysytsia. All rights reserved.
//

import class Foundation.NSURLSession

public class ANSession: NSObject {

    public internal(set) var tasks: Set<ANTask> = []
    
    internal private(set) lazy var session: URLSession = URLSession(configuration: self.configuration, delegate: self, delegateQueue: .main)
    
    private var configuration: URLSessionConfiguration
    
    public init(configuration: URLSessionConfiguration = .default) {
        self.configuration = configuration
    }
    
    internal func task(_ dataTask: URLSessionTask) -> ANTask? {
        return self.tasks.first { $0.task == dataTask }
    }
    
    internal func releaseTask(_ task: ANTask) {
        self.tasks.remove(task)
    }
    
    public func dataTask(with request: ANRequest) -> ANDataTask {
        guard let urlRequest = URLRequest(request: request) else {
            fatalError("\(self) \(#function) \(#line) invalid ANRequest")
        }
        
        let dataTask = self.session.dataTask(with: urlRequest)
        let task = ANDataTask.init(task: dataTask)
        self.tasks.insert(task)
        return task
        
    }
    
    public func downloadTask(with request: ANRequest) -> ANDownloadTask {
        guard let urlRequest = URLRequest(request: request) else {
            fatalError("\(self) \(#function) \(#line) invalid YFNetworkRequest")
        }
        
        let downloadTask = self.session.downloadTask(with: urlRequest)
        let task = ANDownloadTask(task: downloadTask)
        self.tasks.insert(task)
        return task
        
    }

}

// MARK: - URLSessionTaskDelegate
extension ANSession: URLSessionTaskDelegate {
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        guard let task = self.task(task) else { return }
        
        switch task {
        case let dataTask as ANDataTask:
            if let data = dataTask.data, let response = dataTask.httpResponse {
                dataTask.completionHandler?(.success((data, response)))
            } else if let response = dataTask.httpResponse {
                dataTask.completionHandler?(.success((nil, response)))
            } else if let error = error {
                dataTask.completionHandler?(.error(error))
            }
            
        case let downloadTask as ANDownloadTask:
            if let error = error {
                downloadTask.completionHandler?(.error(error))
            }
            
        default: break
        }
        
        self.releaseTask(task)
        
    }
    
}

// MARK: - URLSessionDataDelegate
extension ANSession: URLSessionDataDelegate {
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        guard let task = self.task(dataTask) as? ANDataTask else { return }
        
        if task.data != nil {
            task.data?.append(data)
        } else {
            task.data = data
        }
        
        task.progressHandler?(task.progress)
        
    }
    
}

// MARK: - URLSessionDownloadDelegate
extension ANSession: URLSessionDownloadDelegate {
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        guard let task = self.task(downloadTask) as? ANDownloadTask else { return }
        
        if totalBytesExpectedToWrite > 0 {
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            task.progressHandler?(progress)
        }
        
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let task = self.task(downloadTask) as? ANDownloadTask else { return }
        task.completionHandler?(.success((location, task.response)))
        self.releaseTask(task)
        
    }
    
}
