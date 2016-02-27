//
//  Created by Pierluigi Cifani on 27/02/16.
//  Copyright © 2016 BlurSoftware. All rights reserved.
//

import Cocoa

struct CountryItemModel {
    let countryName: String
}

class CountryItem: NSCollectionViewItem, ConfigurableCell {

    typealias T = CountryItemModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override var representedObject: AnyObject? {
        didSet {
            guard let box = representedObject as? Box<CountryItemModel> else {return}
            configureFor(viewModel: box.value)
        }
    }
    
    func configureFor(viewModel viewModel: CountryItemModel) -> Void {
        let itemView = self.view as! CountryItemView
        itemView.countryNameLabel.stringValue = viewModel.countryName
    }
}

class CountryItemView: NSView {
    @IBOutlet weak var countryNameLabel: NSTextField!
}

// This is included in order to get around a limitation
// of Cocoa APIs where you cannot pass a struct where a property
// expects a Struct. This is the case for the representedObject property
public final class Box<T> {
    public init(_ value: T) {
        self.value = value
    }
    public let value: T
}
