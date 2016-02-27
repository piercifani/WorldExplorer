//
//  Created by Pierluigi Cifani on 27/02/16.
//  Copyright © 2016 BlurSoftware. All rights reserved.
//

import Cocoa
import MapKit

class ResultsViewController: NSViewController {

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
        
        let countries: [Country] = []
        
        dataSource.state = .Values(countries)
    }
}

class CountryDetailView: NSView {
    @IBOutlet weak var mapView: MKMapView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}