//
//  RequestCreator.swift
//  NasaAstronomy
//
//  Created by Sugeet-Home on 12/04/2022.
//

import Foundation

class RequestCreator: NSObject {
    func createRequest(_ baseURLString: String?,
                       requestString: String, httpMethod: String,
                       headerData: NSDictionary?,
                       bodyData: AnyObject?) -> URLRequest {
        let anURL: URL?
        
        if let baseURL = baseURLString {
            if !requestString.contains(baseURL) {
                anURL = URL(string: requestString, relativeTo: URL(string: baseURL))
            } else {
                anURL = URL(string: requestString)
            }
        } else {
            anURL = URL(string: requestString)
        }
        
        let anURLRequest = NSMutableURLRequest(url: anURL!)
        anURLRequest.httpMethod = httpMethod
        
        if let aHeaderData = headerData {
            anURLRequest.allHTTPHeaderFields = aHeaderData as? [String : String]
        }
        
        if let aBodyData = bodyData {
            if aBodyData is Data {
                anURLRequest.httpBody = aBodyData as? Data
            } else {
                anURLRequest.httpBody = try! JSONSerialization.data(withJSONObject: aBodyData, options:[])
                
                if let _ = String(data:anURLRequest.httpBody!, encoding:String.Encoding.utf8), anURLRequest.url?.absoluteString.contains("session") == false {
                }
            }
        }
        
        return anURLRequest as URLRequest
    }
}
