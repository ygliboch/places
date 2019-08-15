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
    func getVenues(completationHandler: @escaping(JSON?)->Void) {
        Alamofire.request("https://api.foursquare.com/v2/venues/search?near=Kiev&client_id=XVXMQC02THLDGUFQWYFAM3MENUB4XGLJKUNAOHYKRCPFPHPI&client_secret=XQ2LSGSQZQXJTIE1N5L5B35VIAID4VSDYHPT03RBBOQA51MI&v=20190302").responseJSON { (response) in
            if response.data != nil && response.error == nil {
                let json = JSON(response.value!)
                completationHandler(json)
            }
        }
    }
    
    func venueInfo(id: String, completationHandler: @escaping(JSON?)->Void) {
        Alamofire.request("https://api.foursquare.com/v2/venues/\(id)&client_id=XVXMQC02THLDGUFQWYFAM3MENUB4XGLJKUNAOHYKRCPFPHPI&client_secret=XQ2LSGSQZQXJTIE1N5L5B35VIAID4VSDYHPT03RBBOQA51MI&v=20190302").responseJSON { (response) in
            if response.data != nil && response.error == nil {
                let json = JSON(response.value!)
                completationHandler(json)
            }
        }
    }
}
