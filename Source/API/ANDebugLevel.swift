//
//  ANDebugLevel.swift
//  AirNetwork
//
//  Created by Yuri Fox on 02.08.2018.
//  Copyright © 2018 Yuri Lysytsia. All rights reserved.
//

import Foundation

public enum ANDebugLevel: Int, CustomStringConvertible {
    
    case none = 0
    case request = 1
    case response = 2
    case all = 3
    
    public var description: String {
        switch self {
        case .none: return "None"
        case .request: return "Only request"
        case .response: return "Only response"
        case .all: return "Requst and response"
        }
    }
    
    func printDescription(for request: ANRequest) {
        guard self == .all || self == .request else { return }
        
        print("===> REQUEST")
        print("\(request.method.rawValue) \(request.path)")
        print("\(request.headerFields?.map { "\($0.key): \($0.value)\n" }.joined() ?? "NULL")")
        
        if let body = request.body {
            print("\(ANRequest.ContentType.key): \(body.contentType.rawValue)\n")
            do {
                let data = try JSONSerialization.data(withJSONObject: body.items, options: .prettyPrinted)
                let jsonString = String(data: data, encoding: .utf8)
                print(jsonString ?? "{ }")
            } catch {
                print("{ }")
            }
            
            print("\(body.items)")
        }
        print("REQUEST <===")
    }
    
    func printDescription(for task: ANTask) {
        guard self == .all || self == .response else { return }
        
        print("===> RESPONSE(\(task.request?.url?.absoluteString ?? "-"))")
        if let response = task.httpResponse {
            print("\(response.statusCode) \(HTTPURLResponse.localizedString(forStatusCode: response.statusCode))")
            print("\(response.allHeaderFields.map { "\($0.key): \($0.value)\n" }.joined())")
            print("\n")
        }
        
        if let data = (task as? ANDataTask)?.data {
            let jsonString = String(data: data, encoding: .utf8)
            print(jsonString ?? "{ }")
        }
        
        print("RESPONSE <===")
    }
    
}
