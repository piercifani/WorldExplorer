//
//  Created by Pierluigi Cifani on 26/02/16.
//  Copyright © 2016 BlurSoftware. All rights reserved.
//

import Foundation

//This is the APIClient for the WoldExplorer API
public class APIClient {
    public let drosky = Drosky()

    //This will fetch the countries for a given region
    func fetchCountriesForRegion(region: Region) -> Deferred<Result<[Country]>>{
        return drosky.performRequest(forEndpoint: region)
                ≈> parseAsyncResponse
    }
}