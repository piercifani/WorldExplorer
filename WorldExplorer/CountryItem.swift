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
    
    override var highlightState: NSCollectionViewItemHighlightState {
        didSet {
            let itemView = self.view as! CountryItemView
            itemView.countryNameLabel.textColor = (highlightState == NSCollectionViewItemHighlightState.ForSelection ? NSColor.blueColor() : NSColor.blackColor())
        }
    }
    
    override func mouseDown(theEvent: NSEvent) {
        super.mouseDown(theEvent)
        
        //This can't be the canonical way of handling selection. Please review later
        guard let delegate = collectionView.delegate as? BridgedCollectionViewDataSource else {return}
        
        delegate.collectionView(collectionView, handleItemSelection: self)
    }
}

class CountryItemView: NSView {
    @IBOutlet weak var countryNameLabel: NSTextField!
}
