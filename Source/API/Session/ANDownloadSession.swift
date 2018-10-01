//
//  ANDownloadSession.swift
//  AirNetwork
//
//  Created by Yuri Fox on 10/1/18.
//  Copyright © 2018 Yuri Lysytsia. All rights reserved.
//

import class Foundation.NSURLSession

public class ANDownloadSession: ANSession<ANDownloadTask>, URLSessionDownloadDelegate {
    
    internal func task(with request: ANRequest) -> ANDownloadTask {
        guard let urlRequest = URLRequest(request: request) else {
            fatalError("\(self) \(#function) \(#line) invalid YFNetworkRequest")
        }
        
        let downloadTask = self.session.downloadTask(with: urlRequest)
        let task = ANDownloadTask(task: downloadTask)
        self.tasks.insert(task)
        return task
        
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        guard let task = self.task(downloadTask) else { return }
        
        if totalBytesExpectedToWrite > 0 {
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            task.progressHandler?(progress)
        }
        
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let task = self.task(downloadTask) else { return }
        task.completionHandler?(.success((location, task.response)))
        self.releaseTask(task)
        
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        guard
            let downloadTask = task as? URLSessionDownloadTask,
            let task = self.task(downloadTask)
            else { return }
        
        if let error = error {
            task.completionHandler?(.error(error))
        }
        
        self.releaseTask(task)
        
    }
    
}
