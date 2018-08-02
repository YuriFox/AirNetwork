//
//  NSNumber+Extension.swift
//  AirNetwork
//
//  Created by Yuri Fox on 02.08.2018.
//  Copyright © 2018 Yuri Lysytsia. All rights reserved.
//

import class Foundation.NSNumber

// MARK: - NSNumber + Extension
extension NSNumber {
    
    private var trueNumber: NSNumber { return NSNumber(value: true) }
    private var falseNumber: NSNumber { return NSNumber(value: false) }
    private var trueObjCType: String { return String(cString: trueNumber.objCType) }
    private var falseObjCType: String { return String(cString: falseNumber.objCType) }
    
    var isBool: Bool {
        let objCType = String(cString: self.objCType)
        return (self.compare(trueNumber) == .orderedSame && objCType == trueObjCType) || (self.compare(falseNumber) == .orderedSame && objCType == falseObjCType)
    }
    
}
