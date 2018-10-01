//
//  ANDataSession.swift
//  AirNetwork
//
//  Created by Yuri Fox on 10/1/18.
//  Copyright © 2018 Yuri Lysytsia. All rights reserved.
//

import class Foundation.NSURLSession

public class ANDataSession: ANSession<ANDataTask>, URLSessionDataDelegate {
 
    private lazy var session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
    
    internal override func task(with request: ANRequest) -> ANTask {
        guard let urlRequest = URLRequest(request: request) else {
            fatalError("\(self) \(#function) \(#line) invalid YFNetworkRequest")
        }
        
        let dataTask = self.session.dataTask(with: urlRequest)
        let task = ANDataTask.init(task: dataTask)
        self.tasks.insert(task)
        return task
        
    }
    
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
        
        guard let sessionTask = self.task(task) else { return }
        
        //        self.debugLevel.printDescription(for: task)
        if let data = sessionTask.data, let response = sessionTask.response {
            sessionTask.completionHandler?(.success((data, response)))
        } else if let response = sessionTask.response {
            sessionTask.completionHandler?(.success((nil, response)))
        } else if let error = error {
            sessionTask.completionHandler?(.error(error))
        }
        
        self.releaseTask(sessionTask)
        //        self.stopNetworkActivity()
        
    }
    
}
