//
//  ANTask.swift
//  AirNetwork
//
//  Created by Yuri Fox on 02.08.2018.
//  Copyright © 2018 Yuri Lysytsia. All rights reserved.
//

import Foundation

public class ANTask: NSObject {
    
    /// The task original request.
    public var request: URLRequest? { return task.originalRequest }
    
    /// The response received from the task.
    public var response: HTTPURLResponse? { return task.response as? HTTPURLResponse }
    
    /// Received data from the task.
    public var data: Data?
    
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
    
    internal var completionHandler: CompletionHandler?
    internal var progressHandler: ProgressHandler?
    
    /// The underlying task.
    internal var task: URLSessionTask
    
    init(task: URLSessionTask) {
        self.task = task
    }
    
    /// Add completion handler of a task.
    ///
    /// - Parameter handler: A closure executed when task completed.
    /// - Returns: This task
    @discardableResult
    public func completion(handler: @escaping CompletionHandler) -> Self {
        self.completionHandler = handler
        return self
    }
    
    /// Add progress handler of a task.
    ///
    /// - Parameters:
    ///   - handler: A closure executed when monitoring progress of a task.
    /// - Returns: This task.
    @discardableResult
    public func progress(handler: @escaping ProgressHandler) -> Self {
        self.progressHandler = handler
        return self
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
    
    /// A closure executed when monitoring progress of a task.
    public typealias ProgressHandler = (Float) -> Void
    
    /// A closure executed when task completed.
    public typealias CompletionHandler = (Data?, HTTPURLResponse?, Error?) -> Void
    
}

public enum ANTaskResult<S: Any, E: Any>: Hashable {
    
    case success(S)
    case error(E)
    
    public var successValue: S? {
        switch self {
        case .success(let successValue): return successValue
        case .error(_): return nil
        }
    }
    
    public var errorValue: E? {
        switch self {
        case .success(_): return nil
        case .error(let errorValue): return errorValue
        }
    }
    
    public var hashValue: Int {
        switch self {
        case .success(_): return 1
        case .error(_): return 0
        }
    }
    
    public static func == (lhs: ANTaskResult, rhs: ANTaskResult) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
}
