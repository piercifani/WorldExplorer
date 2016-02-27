//
//  Created by Pierluigi Cifani on 27/02/16.
//  Copyright © 2016 BlurSoftware. All rights reserved.
//

import Foundation
import Decodable

extension Country: Decodable {

    public static func decode(j: AnyObject) throws -> Country {
        return try Country(
            name : j => "name",
            population: j => "population",
            currencies: j => "currencies"
        )
    }
}
