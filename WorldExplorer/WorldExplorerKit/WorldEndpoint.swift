//
//  Created by Pierluigi Cifani on 26/02/16.
//  Copyright © 2016 BlurSoftware. All rights reserved.
//

import Foundation

let BaseURL = "https://restcountries.eu/rest/v1/"

extension Region: Endpoint {
    public var path: String {
        
        let value: String
        
        switch self {
        case .Europe:
            value = "europe"
        case .Africa:
            value = "africa"
        case .Asia:
            value = "asia"
        case .Oceania:
            value = "oceania"
        case .America:
            value = "americas"
        }
        
        return BaseURL + "region/" + value
    }
}