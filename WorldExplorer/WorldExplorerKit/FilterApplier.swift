//
//  Created by Pierluigi Cifani on 28/02/16.
//  Copyright © 2016 BlurSoftware. All rights reserved.
//

import Foundation

class FilterApplier {
    let operationQueue = NSOperationQueue()
    var currentFilter = Filter.emptyFilter()
    
    func applyFilterToCountries(countries: [Country]) -> Deferred<[Country]> {
        
        let deferred = Deferred<[Country]>()
        
        operationQueue.addOperationWithBlock {
            
            //This is the most basic implementation of filtering
            
            let filteredMinPopulationCountries = countries.filter({ (country) -> Bool in
                if let minPopulation = self.currentFilter.minPopulation {
                    return (country.population > minPopulation)
                } else {
                    return true
                }
            })
            
            let filteredMaxPopulationCountries = countries.filter({ (country) -> Bool in
                if let maxPopulation = self.currentFilter.maxPopulation {
                    return (country.population < maxPopulation)
                } else {
                    return true
                }
            })
            
            let filteredCurrencyCountries = countries.filter({ (country) -> Bool in
                if let currency = self.currentFilter.currency {
                    return country.currencies.contains({
                        return $0.lowercaseString.rangeOfString(currency.lowercaseString) != nil
                    })
                } else {
                    return true
                }
            })
            
            let set1 = Set(filteredMinPopulationCountries)
            let set2 = Set(filteredMaxPopulationCountries)
            let set3 = Set(filteredCurrencyCountries)
            
            deferred.fill(Array(set1.intersect(set2).intersect(set3)))
        }
        
        return deferred
    }
}

