//
//  ANDownloadTask.swift
//  AirNetwork
//
//  Created by Yuri Fox on 10/1/18.
//  Copyright © 2018 Yuri Lysytsia. All rights reserved.
//

import class Foundation.NSURLSession

public class ANDownloadTask: ANTask {
    
    /// Location of received data from the task.
    public internal(set) var location: URL?
    
    internal var completionHandler: CompletionHandler?
    
    /// Add completion handler of a task.
    ///
    /// - Parameter handler: A closure executed when task completed.
    /// - Returns: This task
    @discardableResult
    public func completion(handler: @escaping CompletionHandler) -> Self {
        self.completionHandler = handler
        return self
    }
    
    /// A closure executed when task completed.
    public typealias CompletionHandler = (ANTaskResult<(location: URL, response: URLResponse?), Error>) -> Void
    
}
