//
//  ANSession.swift
//  AirNetwork
//
//  Created by Yuri Fox on 10/1/18.
//  Copyright © 2018 Yuri Lysytsia. All rights reserved.
//

import class Foundation.NSURLSession

public class ANSession<Task: ANTask>: NSObject, URLSessionTaskDelegate {

    public internal(set) var tasks: Set<Task> = []
    
    internal lazy var session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        
    internal func task(_ dataTask: URLSessionTask) -> Task? {
        return self.tasks.first { $0.task == dataTask }
    }

    internal func releaseTask(_ task: Task) {
        self.tasks.remove(task)
    }

}
