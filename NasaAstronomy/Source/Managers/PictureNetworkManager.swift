//
//  PictureNetworkManager.swift
//  NasaAstronomy
//
//  Created by Sugeet-Home on 12/04/2022.
//

import UIKit

class PictureNetworkManager: BaseNetworkManager {
    private var aCallBackObject: ApiCallBack?
    var apiName = APIName.unknown
    
    func getPictureOfTheDay(for requestModel: PictureRequest, callBackObject: ApiCallBack) -> Void {
        aCallBackObject = callBackObject
        apiName = .getPictures
        
        let anAPIPath = String(format: APIURL.getPictures.rawValue, requestModel.date ?? "")
        let networkRequestModel = CloudNetworkRequestModel.init(extensionURL: anAPIPath, bodyData: nil, requestType: HttpRequestType.GET, observer: self)
        super.execute(networkRequestModel)
    }
    
    override func onComplete(_ data: AnyObject) -> Void {
        switch apiName {
        case .getPictures:
            let aPictureResponse = PictureResponse()
            
            if let aData = data as? Dictionary<String, AnyObject> {
                let _ = aPictureResponse.updateData(aData)
            }
            
            aCallBackObject?.onSuccess(aPictureResponse, apiName)
        default:
            print("Unknown API Completion Call back")
        }
    }
    
    override func onError(_ errorResponse: ErrorResponse) -> Void {
        print("TestNetworkManager onError-> \(errorResponse)")
        aCallBackObject?.onError(errorResponse, apiName: apiName)
    }
}
