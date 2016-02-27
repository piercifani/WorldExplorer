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

    func configureFor(viewModel viewModel: CountryItemModel) -> Void {
        let itemView = self.view as! CountryItemView
        itemView.countryNameLabel.stringValue = viewModel.countryName
    }
}

class CountryItemView: NSView {
    @IBOutlet weak var countryNameLabel: NSTextField!
}
