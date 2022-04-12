//
//  CloudNetworkRequestModel.swift
//  NasaAstronomy
//
//  Created by Sugeet-Home on 12/04/2022.
//

import UIKit

public enum HttpRequestType:String {
    case GET = "GET"
    case POST = "POST"
    case DELETE = "DELETE"
    case PUT = "PUT"
}

class CloudNetworkRequestModel {
    fileprivate let NO_OF_RETRIES = 1
    var apiPath:String?
    var bodyData:AnyObject?
    var requestType:HttpRequestType?
    var observer:BaseNetworkManager?
    var retryCount = 0
    var customURL = false
    
    init(extensionURL:String,
         bodyData:AnyObject?,
         requestType:HttpRequestType,
         observer:BaseNetworkManager) {
        self.apiPath = extensionURL
        self.bodyData = bodyData
        self.requestType = requestType
        self.observer = observer
    }
    
    init(extensionURL:String,
         requestType:HttpRequestType,
         observer:BaseNetworkManager) {
        self.apiPath = extensionURL
        self.requestType = requestType
        self.observer = observer
    }
    
    func setRetry(){
        retryCount += 1
    }
    
    func hasRetry() -> Bool {
        return (retryCount >= NO_OF_RETRIES)
    }
}
