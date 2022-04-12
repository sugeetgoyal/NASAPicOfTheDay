//
//  BaseNetworkManager.swift
//  NasaAstronomy
//
//  Created by Sugeet-Home on 12/04/2022.
//

import UIKit

enum APIName: String {
    case getPictures = "getPictures"
    case unknown = "unknown"
}

enum APIURL: String {
    //Replace the value of API key here
    case getPictures = "apod?api_key=4P4PAcxlrt6zSbZLlLlPL7MeCGObELkMao1XXaHy&date=%@"
}

class ErrorResponse : NSObject {
    var code: Int = 0
    var message: String = "There is a technical error, we are working on it."
}

enum code : Int {
    case UserAlreadyRegisteredNotActivated, Unknown
}

@objc protocol NetworkCallBack {
    @objc func onComplete(_ obj: AnyObject) -> Void
    @objc func onError(_ errorResponse: ErrorResponse) -> Void
}

protocol ApiCallBack {
    func onSuccess(_ data: AnyObject?, _ apiName: APIName)
    func onError(_ errorResponse: ErrorResponse, apiName: APIName)
}

extension ApiCallBack {
    func onSuccess(_ data: AnyObject?, _ apiName: APIName) {}
    func onError(_ errorResponse: ErrorResponse, apiName: APIName) {}
}

protocol RESTClientProtocol : class {
    func didSucceedSilentLogin()
    func onFailureWithSilentLogin(error: ErrorResponse) -> Void
}

class NetworkEnvironment {
    public static let sharedInstance = NetworkEnvironment()
    
    var baseURLString = "https://api.nasa.gov/planetary/"
    
    var CSRFToken = String()
    
    public let baseHeader: NSMutableDictionary = ["Accept" : "application/json",
                                                  "Content-Type" : "application/json",
                                                  "Accept-Version": "v1"]
}

class BaseNetworkManager: NSObject {
    let networkEnvironment = NetworkEnvironment.sharedInstance
    
    func execute(_ requestModel: CloudNetworkRequestModel,
                 contentType: String = "application/json; charset=utf-8",
                 isOldAziksaAPI: Bool = false) -> Void {
        self.networkEnvironment.baseHeader["Content-Type"] = contentType
        
        let aHeaders = self.networkEnvironment.baseHeader.mutableCopy() as? NSMutableDictionary
        
        if requestModel.customURL {
            RestClient.sharedInstance.baseURLString = ""
            
        } else {
            RestClient.sharedInstance.baseURLString = networkEnvironment.baseURLString
        }
        
        RestClient.sharedInstance.createRequestAndExecuteCall(requestModel.apiPath!,
                                                              httpMethod: (requestModel.requestType?.rawValue)!,
                                                              headerData: aHeaders,
                                                              bodyData: requestModel.bodyData,
                                                              requestContainsBaseURL: false,
                                                              completionBlock: {(isRequestSuccessful: Bool,
                                                                                 result: Any?,
                                                                                 response: HTTPURLResponse?,
                                                                                 error: NSError?) -> Void in
                                                                self.handleResponse(requestModel: requestModel, isRequestSuccessful: isRequestSuccessful, result: result, response: response, error: error)
                                                              })
    }
    
    //MARK: - Call back Handlers
    private func handleResponse(requestModel: CloudNetworkRequestModel,
                                isRequestSuccessful: Bool,
                                result: Any?,
                                response: HTTPURLResponse?,
                                error: NSError?) {
        DispatchQueue.main.async(execute: {
            if isRequestSuccessful &&  result != nil {
                if (result is NSArray == true) {
                    requestModel.observer?.onComplete(result! as AnyObject)
                } else if result is NSDictionary {
                    requestModel.observer?.onComplete(result as AnyObject)
                } else if result is UIImage {
                    requestModel.observer?.onComplete(result! as! UIImage)
                } else if result is Bool == true {
                    requestModel.observer?.onComplete(result! as AnyObject)
                } else {
                    let anErrorResponse = ErrorResponse()
                    let (aCode, aMessage) = self.getErrorMessageAndCode(requestModel: requestModel, withResult: result as AnyObject?, withError: error, andResponse: response)
                    anErrorResponse.message = aMessage
                    anErrorResponse.code = aCode
                }
            } else {
                let anErrorResponse = ErrorResponse()
                let (aCode, aMessage) = self.getErrorMessageAndCode(requestModel: requestModel, withResult: result as AnyObject?, withError: error, andResponse: response)
                anErrorResponse.message = aMessage
                anErrorResponse.code = aCode
                requestModel.observer?.onError(anErrorResponse)
            }
        })
    }
    
    //MARK: - Support method
    private func getErrorMessageAndCode(requestModel: CloudNetworkRequestModel, withResult aResult: AnyObject?, withError anError: NSError?, andResponse aResponse: HTTPURLResponse?) -> (Int, String) {
        var anErrorMessage = anError?.localizedDescription ?? (aResponse?.description ?? "Unknown Error!")
        
        if aResult != nil {
            if aResult is NSDictionary {
                if let anErrorDictionary = aResult as? NSDictionary {
                    if let aMessage = anErrorDictionary["message"] as? String {
                        anErrorMessage = aMessage
                    }
                    
                    if let aMessage = anErrorDictionary["error"] as? String {
                        anErrorMessage = aMessage
                    }
                    
                    if let errors = (anErrorDictionary["errors"] as? [String]), errors.count > 0  {
                        anErrorMessage = errors[0]
                    }
                }
            }
        }
        
        return (anError?.code ?? 0, anErrorMessage)
    }
}

extension BaseNetworkManager: NetworkCallBack {
    func onComplete(_ obj: AnyObject) -> Void {}
    
    func onError(_ errorResponse: ErrorResponse) -> Void {}
}
