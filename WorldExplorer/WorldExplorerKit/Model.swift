//
//  Created by Pierluigi Cifani on 27/02/16.
//  Copyright © 2016 BlurSoftware. All rights reserved.
//

import Foundation

public struct Country {
    let name: String
    let population: Double
    let currencies: [String]
}

extension Country: Hashable {
    public var hashValue: Int {
        return name.hashValue ^ population.hashValue ^ currencies.joinWithSeparator("&").hashValue
    }
}

public func ==(lhs: Country, rhs: Country) -> Bool {
    return lhs.name == rhs.name
}

public enum Region {
    case Europe
    case Africa
    case Asia
    case Oceania
    case America
}

public struct Filter {
    let minPopulation: Double?
    let maxPopulation: Double?
    let currency: String?
    
    static func emptyFilter() -> Filter {
        return Filter(minPopulation: nil, maxPopulation: nil, currency: nil)
    }
}