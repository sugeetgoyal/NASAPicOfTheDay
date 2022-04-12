//
//  RestClient.swift
//  NasaAstronomy
//
//  Created by Sugeet-Home on 12/04/2022.
//

import UIKit

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

let RESTCLIENT_LOG_TAG = "REST_CLIENT_LOG"

extension RestClient: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}

class RestClient: NSObject {
    public static let sharedInstance = RestClient()
    var baseURLString : String?
    
    lazy var session: URLSession = {
        let aSessionConfiguration = URLSessionConfiguration.default
        aSessionConfiguration.httpMaximumConnectionsPerHost = 6
        
        URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        
        let session = URLSession(configuration: aSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        return session
    }()
    
    override init() {
        super.init()
    }
    
    func createRequestAndExecuteCall(_ requestString: String,
                                     httpMethod: String,
                                     headerData: NSDictionary?,
                                     bodyData: AnyObject?,
                                     requestContainsBaseURL: Bool,
                                     completionBlock: @escaping (_ isRequestSuccessful: Bool,
                                                                 _ result: Any?,
                                                                 _ response: HTTPURLResponse?,
                                                                 _ error: NSError?) -> Void) -> Void {
        let aRequestCreator = RequestCreator()
        let baseURL = requestContainsBaseURL ? nil : self.baseURLString
        let anURLRequest = aRequestCreator.createRequest(baseURL, requestString: requestString, httpMethod: httpMethod, headerData: headerData, bodyData:bodyData)
        self.executeServerCall(anURLRequest, completionBlock:completionBlock)
    }
    
    func executeServerCall(_ urlRequest: URLRequest,
                           completionBlock: @escaping (_ isRequestSuccessful: Bool,
                                                       _ result: Any?,
                                                       _ response: HTTPURLResponse?,
                                                       _ error: NSError?) -> Void) -> Void {
        print("\(RESTCLIENT_LOG_TAG) -> network call initiated")
        print("\(RESTCLIENT_LOG_TAG) -> \(urlRequest)")
        
        let aSessionDataTask = self.session.dataTask(with: urlRequest, completionHandler: {(data, response, error) in
            if let anHTTPURLResponse = response as? HTTPURLResponse {
                print(anHTTPURLResponse)
                
                if (anHTTPURLResponse.statusCode >= 200 && anHTTPURLResponse.statusCode < 300 && error == nil) {
                    if data?.count > 0 {
                        
                        do {
                            var aResult: Any?
                            
                            if let anImage = UIImage(data: data!) {
                                aResult = anImage
                            } else {
                                aResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments)
                                print(aResult as Any)
                            }
                            
                            completionBlock(true, aResult as Any?, anHTTPURLResponse, nil)
                        } catch let JSONError as NSError {
                            print("\(RESTCLIENT_LOG_TAG) -> ERROR: Unable to serialize json, error: \(JSONError)")
                            completionBlock(false, nil, anHTTPURLResponse, JSONError as NSError)
                        }
                    } else {
                        print("\(RESTCLIENT_LOG_TAG) -> message: Request Succesful")
                        completionBlock(true, nil, anHTTPURLResponse, nil)
                    }
                } else {
                    print("\(RESTCLIENT_LOG_TAG) -> executeServerCall failed")
                    completionBlock(false, nil, anHTTPURLResponse, error as NSError?)
                }
                
            } else {
                if error != nil {
                    print("\(RESTCLIENT_LOG_TAG) -> executeServerCall failed")
                    print("\(RESTCLIENT_LOG_TAG) -> \(error!)")
                    completionBlock(false, nil, nil, error as NSError?)
                } else {
                    print("\(RESTCLIENT_LOG_TAG) -> Request Failed")
                    completionBlock(false, nil, nil, nil)
                }
            }
        })
        
        aSessionDataTask.resume()
    }
}
