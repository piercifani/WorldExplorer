//
//  Created by Pierluigi Cifani on 27/02/16.
//  Copyright © 2016 BlurSoftware. All rights reserved.
//

import Cocoa
import MapKit

class CountryController: NSViewController, RegionPickerObserver {
    
    var apiClient: APIClient!

    @IBOutlet weak var filterHandlerView: FilterHandlerView!
    @IBOutlet weak var countryListView: CountryListView!
    @IBOutlet weak var countryDetailView: CountryDetailView!

    //MARK: - RegionPickerObserver
    func onRegionPicked(region: Region) {
        
        //TODO: Maybe throttle how often the user can change the region?
        
        countryListView.dataSource.state = .Loading
        apiClient.fetchCountriesForRegion(region).uponMainQueue { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .Failure(let error):
                strongSelf.countryListView.dataSource.state = .Error(error)
            case .Success(let value):
                strongSelf.countryListView.dataSource.state = .Values(value)
            }
        }
    }
}

class FilterHandlerView: NSView, NSTextFieldDelegate {
    
    @IBOutlet weak var populationMinTextField: NSTextField!
    @IBOutlet weak var populationMaxTextField: NSTextField!
    @IBOutlet weak var currencyTextField: NSTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        populationMinTextField.delegate = self
        populationMaxTextField.delegate = self
        currencyTextField.delegate = self
    }
    
    internal override func controlTextDidChange(obj: NSNotification) {
    
    }
}

class CountryListView: NSView {
    @IBOutlet weak var collectionView: NSCollectionView!
    var dataSource: CollectionViewDataSource<Country, CountryItem>!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dataSource = CollectionViewDataSource(
            collectionView: collectionView,
            mapper: { country in
                return CountryItemModel(countryName:country.name)
        })
    }
}

class CountryDetailView: NSView {
    @IBOutlet weak var mapView: MKMapView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}