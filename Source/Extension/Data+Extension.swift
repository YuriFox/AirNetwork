//
//  Data+Extension.swift
//  AirNetwork
//
//  Created by Yuri Fox on 02.08.2018.
//  Copyright © 2018 Yuri Lysytsia. All rights reserved.
//

import Foundation.NSData

extension Data {
    
    mutating func append(string: String) {
        guard let data = string.data(using: .utf8) else { return }
        self.append(data)
    }

    mutating func append(value: Any, forKey key: String, boundary: String) {
        self.append(string: "--\(boundary)\r\n")
        self.append(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
        self.append(string: "\(value)\r\n")
    }
    
    mutating func append(file: ANMultipartFile, forKey key: String, boundary: String) {
        self.append(string: "--\(boundary)\r\n")
        if let filename = file.name {
            self.append(string: "Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(filename)\"\r\n")
        } else {
            self.append(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n")
        }
        self.append(string: "Content-Type: \(file.mimeType)\r\n\r\n")
        self.append(file.data)
        self.append(string: "\r\n")
    }
    
}
