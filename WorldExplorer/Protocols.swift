//
//  Created by Pierluigi Cifani on 28/02/16.
//  Copyright © 2016 BlurSoftware. All rights reserved.
//

import Foundation

//MARK: - RegionPickerObserver

protocol RegionPickerObserver: class {
    func onRegionPicked(region: Region)
}

//MARK: - FilterHandlerProtocol

protocol FilterHandlerProtocol: class {
    func didUpdateMinPopulation(maxPopulation: String)
    func didUpdateMaxPopulation(maxPopulation: String)
    func didUpdateCurrency(currency: String)
}
