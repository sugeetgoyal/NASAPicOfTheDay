//
//  HomeViewModel.swift
//  NasaAstronomy
//
//  Created by Sugeet-Home on 12/04/2022.
//

import Foundation
let CachedResponseKey = "CachedResponse"

class HomeViewModel {
    var date: String?
    var title: String?
    var description: String?
    var mediaURL: String?
    var media_type: MediaType?
    let cache = NSCache<NSString, PictureResponse>()
    var completionBlock: ((Bool, String) -> Void)?
    var hasError: Bool = false
    
    func getPictureOfTheDay(_ queryDate: Date, completion: @escaping (_ success: Bool,_ error:String) -> Void) {
        let aRequestModel = PictureRequest()
        aRequestModel.date = queryDate.toString()
        
        APIRouter().getPictureOfTheDay(for: aRequestModel, callBackObject: self)
        completionBlock = completion
    }
    
    func updateResponse(response:PictureResponse) {
        self.date = response.date
        self.title = response.title
        self.description = response.explanation
        self.mediaURL = response.url
        self.media_type = response.media_type
    }
}

extension HomeViewModel: ApiCallBack {
    func onSuccess(_ data: AnyObject?, _ apiName: APIName) -> Void {
        if let aResponse = data as? PictureResponse {
            self.updateResponse(response: aResponse)
            cache.setObject(aResponse, forKey: CachedResponseKey as NSString)
            hasError = false
            completionBlock?(true, "")
        }
    }
    
    func onError(_ errorResponse: ErrorResponse, apiName: APIName) {
        hasError = true
        completionBlock?(false, errorResponse.message)
    }
}

