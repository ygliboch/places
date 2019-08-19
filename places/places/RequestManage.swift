//
//  RequestManage.swift
//  places
//
//  Created by Yaroslava HLIBOCHKO on 8/12/19.
//  Copyright © 2019 Yaroslava HLIBOCHKO. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class RequestManager {
    
    let clientId = "XO5VPDNEMGEYXB4C4HK4Q0W5MFLNC0E15TAMQCH5I1VG2QRU"
    let clientSecret = "XSMQDTU1VGO40S5NHCM1NIEU2X0OYI4O2ANGXSOGYSIDAQXY"
    
    func getVenues(completationHandler: @escaping(JSON?)->Void) {
        Alamofire.request("https://api.foursquare.com/v2/venues/search?near=Kiev&client_id=\(clientId)&client_secret=\(clientSecret)&v=20190302").responseJSON { (response) in
            if response.data != nil && response.error == nil {
                let json = JSON(response.value!)
                print(json)
                completationHandler(json)
            }
        }
    }
    
    func venueInfo(id: String, completationHandler: @escaping(JSON?)->Void) {
        Alamofire.request("https://api.foursquare.com/v2/venues/\(id)?&client_id=\(clientId)&client_secret=\(clientSecret)&v=20190302").responseJSON { (response) in
            if response.data != nil && response.error == nil {
                let json = JSON(response.value!)
                completationHandler(json)
            }
        }
    }
}
