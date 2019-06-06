//
//  ANTaskResult.swift
//  AirNetwork
//
//  Created by Yuri Fox on 11.08.2018.
//  Copyright © 2018 Yuri Lysytsia. All rights reserved.
//

import Foundation

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
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .success(_): hasher.combine(1)
        case .error(_): hasher.combine(-1)
        }
    }
    
    public static func == (lhs: ANTaskResult, rhs: ANTaskResult) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
}
