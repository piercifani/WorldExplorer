//
//  WorldAPIClient.swift
//  WorldExplorer
//
//  Created by Pierluigi Cifani on 26/02/16.
//  Copyright © 2016 BlurSoftware. All rights reserved.
//

import Foundation

public class APIClient {
    public let drosky = Drosky()

    func fetchCountriesForRegion(region: Region) -> Deferred<Result<Void>>{
        return drosky.performRequest(forEndpoint: region)
                ≈> parseEmptyResponse
    }
}