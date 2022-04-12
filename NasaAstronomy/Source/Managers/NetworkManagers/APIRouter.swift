//
//  APIRouter.swift
//  NasaAstronomy
//
//  Created by Sugeet-Home on 12/04/2022.
//

class APIRouter {
    func getPictureOfTheDay(for requestModel: PictureRequest, callBackObject: ApiCallBack) {
        PictureNetworkManager().getPictureOfTheDay(for: requestModel, callBackObject: callBackObject)
    }
}
