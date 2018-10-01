//
//  ANTask.swift
//  AirNetwork
//
//  Created by Yuri Fox on 02.08.2018.
//  Copyright © 2018 Yuri Lysytsia. All rights reserved.
//

import class Foundation.NSURLSession

public class ANDataTask: ANTask {

    /// Received data from the task.
    public internal(set) var data: Data?
    
    internal var completionHandler: CompletionHandler?
    
    /// Add completion handler of a task.
    ///
    /// - Parameter handler: A closure executed when task completed.
    /// - Returns: This task
    public func completion(handler: @escaping CompletionHandler) -> Self {
        self.completionHandler = handler
        return self
    }
    
    /// A closure executed when task completed.
    public typealias CompletionHandler = (ANTaskResult<(data: Data?, response: URLResponse?), Error>) -> Void
    
}
