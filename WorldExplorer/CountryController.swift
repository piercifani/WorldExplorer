//
//  Created by Pierluigi Cifani on 27/02/16.
//  Copyright © 2016 BlurSoftware. All rights reserved.
//

import Cocoa
import MapKit

class CountryController: NSViewController, RegionPickerObserver, FilterHandlerProtocol {
    
    var apiClient: APIClient!

    @IBOutlet weak var filterHandlerView: FilterHandlerView!
    @IBOutlet weak var countryListView: CountryListView!
    @IBOutlet weak var countryDetailView: CountryDetailView!
    
    var filterApplier = FilterApplier()
    var currentRegionCountries: [Country]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterHandlerView.filterDelegate = self
    }
    
    func onCountrySelection(country: Country) {
        countryDetailView.presentDetailsForCountry(country)
    }

    //MARK: - RegionPickerObserver
    func onRegionPicked(region: Region) {
        
        //TODO: Maybe throttle how often the user can change the region?
        
        //This should be on viewDidLoad, but don't know how to do that yet
        countryListView.countrySelectHandler = onCountrySelection
        
        countryListView.dataSource.state = .Loading
        let deferred = apiClient.fetchCountriesForRegion(region)
                        ≈> storeLastRequestCountries
                        ≈> filterApplier.applyFilterToCountries
        
        deferred.uponMainQueue { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .Failure(let error):
                strongSelf.countryListView.dataSource.state = .Error(error)
            case .Success(let value):
                strongSelf.countryListView.dataSource.state = .Values(value)
            }
        }
    }
    
    //MARK: - FilterHandlerProtocol
    func didUpdateMinPopulation(minPopulation: String) {
        let currentFilter = filterApplier.currentFilter
        let newMinPopulation: Double? = minPopulation.characters.count == 0 ? nil : Double(minPopulation)
        let newFilter = Filter(minPopulation:newMinPopulation, maxPopulation:currentFilter.maxPopulation, currency: currentFilter.currency)
        filterUpdated(newFilter)
    }
    
    func didUpdateMaxPopulation(maxPopulation: String) {
        let currentFilter = filterApplier.currentFilter
        let newMaxPopulation: Double? = maxPopulation.characters.count == 0 ? nil : Double(maxPopulation)
        let newFilter = Filter(minPopulation:currentFilter.minPopulation, maxPopulation:newMaxPopulation, currency: currentFilter.currency)
        filterUpdated(newFilter)
    }
    
    func didUpdateCurrency(currency: String) {
        let currentFilter = filterApplier.currentFilter
        let newCurrency: String? = currency.characters.count == 0 ? nil : currency
        let newFilter = Filter(minPopulation:currentFilter.minPopulation, maxPopulation:currentFilter.maxPopulation, currency: newCurrency)
        filterUpdated(newFilter)
    }
    
    //MARK: Private
    
    func filterUpdated(filter: Filter) {
        guard let currentRegionCountries = self.currentRegionCountries else { return }

        filterApplier.currentFilter = filter
        countryListView.dataSource.state = .Loading
        filterApplier.applyFilterToCountries(currentRegionCountries).uponMainQueue { [weak self] values in
            guard let strongSelf = self else { return }
            strongSelf.countryListView.dataSource.state = .Values(values)
        }
    }
    
    func storeLastRequestCountries(countries: [Country]) -> Deferred<[Country]> {
        self.currentRegionCountries = countries
        return Deferred<[Country]>(value: countries)
    }
}

protocol FilterHandlerProtocol: class {
    func didUpdateMinPopulation(maxPopulation: String)
    func didUpdateMaxPopulation(maxPopulation: String)
    func didUpdateCurrency(currency: String)
}

class FilterHandlerView: NSView, NSTextFieldDelegate {
    
    @IBOutlet weak var populationMinTextField: NSTextField!
    @IBOutlet weak var populationMaxTextField: NSTextField!
    @IBOutlet weak var currencyTextField: NSTextField!
    
    weak var filterDelegate: FilterHandlerProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        populationMinTextField.delegate = self
        populationMaxTextField.delegate = self
        currencyTextField.delegate = self
    }
    
    internal override func controlTextDidChange(obj: NSNotification) {
        guard let object = obj.object as? NSObject else { return }
        if object == populationMinTextField {
            filterDelegate?.didUpdateMinPopulation(populationMinTextField.stringValue)
        } else if object == populationMaxTextField {
            filterDelegate?.didUpdateMaxPopulation(populationMaxTextField.stringValue)
        } else if object == currencyTextField {
            filterDelegate?.didUpdateCurrency(currencyTextField.stringValue)
        }
    }
}

class CountryListView: NSView {
    @IBOutlet weak var collectionView: NSCollectionView!
    var dataSource: CollectionViewDataSource<Country, CountryItem>!
    var countrySelectHandler: (Country -> Void)? {
        didSet{
            dataSource.tapHandler = countrySelectHandler
        }
    }
    
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
    @IBOutlet weak var countryNameLabel: NSTextField!
    @IBOutlet weak var populationLabel: NSTextField!
    @IBOutlet weak var currencyLabel: NSTextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func presentDetailsForCountry(country: Country) {
        countryNameLabel.stringValue = country.name
        populationLabel.stringValue = "\(country.population)"
        currencyLabel.stringValue = country.currencies.joinWithSeparator(", ")
    }
}