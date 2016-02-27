//
//  Created by Pierluigi Cifani on 26/02/16.
//  Copyright © 2016 BlurSoftware. All rights reserved.
//

import Cocoa

class RegionController: NSViewController {

    var apiClient: APIClient!

    //TODO: This should be handled with a CollectionView or TableView, so we don't have all these IBActions

    @IBAction func onSelectAfrica(sender: AnyObject) {
        apiClient.fetchCountriesForRegion(.Africa)
    }
    
    @IBAction func onSelectEurope(sender: AnyObject) {
        apiClient.fetchCountriesForRegion(.Europe)
    }
    
    @IBAction func onSelectAmericas(sender: AnyObject) {
        apiClient.fetchCountriesForRegion(.America)
    }
    
    @IBAction func onSelectOceania(sender: AnyObject) {
        apiClient.fetchCountriesForRegion(.Oceania)
    }
    
    @IBAction func onSelectAsia(sender: AnyObject) {
        apiClient.fetchCountriesForRegion(.Asia)
    }
}

