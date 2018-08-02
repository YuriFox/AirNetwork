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
    
    mutating func append(multipartFile file: ANRequest.MultipartFile, forKey key: String, boundary: String) {
        
        for (key, value) in file.bodyItems {
            self.append(string: "--\(boundary)\r\n")
            self.append(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            self.append(string: "\(value)\r\n")
        }
        
        self.append(string: "--\(boundary)\r\n")
        self.append(string: "Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(file.name)\"\r\n")
        self.append(string: "Content-Type: \(file.mimeType)\r\n\r\n")
        self.append(file.data)
        self.append(string: "\r\n")
    }
    
}
