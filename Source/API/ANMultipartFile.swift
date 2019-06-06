//
//  ANMultipartFile.swift
//  AirNetwork
//
//  Created by Yuri Fox on 13.08.2018.
//  Copyright © 2018 Yuri Lysytsia. All rights reserved.
//

import UIKit.UIImage

public struct ANMultipartFile: JSONEncodable {
    
    public let name: String?
    public let data: Data
    public let mimeType: String
    
    public var json: JSON {
        return JSON(self)
    }
    
    private init(name: String?, data: Data, mimeType: String) {
        self.name = name
        self.data = data
        self.mimeType = mimeType
    }
    
    private static var uniqueName: String {
        return UUID().uuidString
    }
    
    public init?(json: [String : Any]) {
        guard let data = json.jsonData else { return nil }
        self.init(name: nil, data: data, mimeType: "application/json")
    }
    
    public init?(urlEncoded: [String : Any], using encoding: String.Encoding = .utf8) {
        guard let data = urlEncoded.urlEncodedData(using: encoding) else { return nil }
        self.init(name: nil, data: data, mimeType: "application/x-www-form-urlencoded")
    }
    
    public init?(imageJPEG: UIImage, quality: CGFloat = 1, name: String? = nil) {
        guard let data = imageJPEG.jpegData(compressionQuality: quality) else { return nil }
        let name = "\(name ?? ANMultipartFile.uniqueName).jpeg"
        self.init(name: name, data: data, mimeType: "image/jpeg")
    }
    
    public init?(imagePNG: UIImage, name: String? = nil) {
        guard let data = imagePNG.pngData() else { return nil }
        let name = "\(name ?? ANMultipartFile.uniqueName).png"
        self.init(name: name, data: data, mimeType: "image/png")
    }
    
    public init?(videoMOV url: URL, name: String? = nil) {
        guard let data = try? Data(contentsOf: url, options: []) else { return nil }
        let name = "\(name ?? ANMultipartFile.uniqueName).mov"
        self.init(name: name, data: data, mimeType: "video/mov")
    }
    
}
