//
//  ANTask.swift
//  AirNetwork
//
//  Created by Yuri Fox on 10/1/18.
//  Copyright © 2018 Yuri Lysytsia. All rights reserved.
//

import class Foundation.NSURLSession

public class ANTask: NSObject {
    
    /// The task original request.
    public var request: URLRequest? { return task.originalRequest }
    
    /// The response received from the task.
    public var response: URLResponse? { return task.response }
    
    /// The HTTP response received from the task.
    public var httpResponse: HTTPURLResponse? { return self.response as? HTTPURLResponse }
    
    /// The current state of the task.
    public var state: URLSessionTask.State {
        return self.task.state
    }
    
    /// A representation of task progress
    public var progress: Float {
        let downloaded = Float(self.task.countOfBytesReceived)
        let length = Float(self.task.countOfBytesExpectedToReceive)
        return downloaded/length
    }
    
    internal var progressHandler: ProgressHandler?
    
    internal var task: URLSessionTask
    
    public init(task: URLSessionTask) {
        self.task = task
    }
    
    /// Resumes the task, if it is suspended.
    public func resume() {
        self.task.resume()
    }
    
    /// Temporarily suspends a task.
    public func suspend() {
        self.task.suspend()
    }
    
    /// Cancels the task.
    public func cancel() {
        self.task.cancel()
    }
    
    /// Add progress handler of a task.
    ///
    /// - Parameters:
    ///   - handler: A closure executed when monitoring progress of a task.
    /// - Returns: This task.
    public func progress(handler: @escaping ProgressHandler) -> Self {
        self.progressHandler = handler
        return self
    }
    
    /// A closure executed when monitoring progress of a task.
    public typealias ProgressHandler = (Float) -> Void

    
}
