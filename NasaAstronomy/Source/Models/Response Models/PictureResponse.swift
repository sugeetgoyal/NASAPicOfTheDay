//
//  PictureResponse.swift
//  NasaAstronomy
//
//  Created by Sugeet Goyal on 12/04/22.
//

import Foundation

enum MediaType {
    case video, audio, image, unknown
}

class PictureResponse: BaseResponseModel {
    var date: String?
    var title: String?
    var explanation: String?
    var hdurl: String?
    var url: String?
    var media_type = MediaType.unknown
    
    func updateData(_ data: Dictionary<String, AnyObject>) -> PictureResponse {
        if let aVal = data["date"] as? String {
            self.date = aVal
        }

        if let aVal = data["title"] as? String {
            self.title = aVal
        }

        if let aVal = data["explanation"] as? String {
            self.explanation = aVal
        }

        if let aVal = data["hdurl"] as? String {
            self.hdurl = aVal
        }

        if let aVal = data["url"] as? String {
            self.url = aVal
        }

        if let aVal = data["media_type"] as? String {
            if aVal == "audio" {
                self.media_type = .audio
            } else if aVal == "video" {
                self.media_type = .video
            } else if aVal == "image" {
                self.media_type = .image
            } else {
                self.media_type = .unknown
            }
        }
        
        return self
    }
}
