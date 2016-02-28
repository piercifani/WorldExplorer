//
//  Created by Pierluigi Cifani on 26/02/16.
//  Copyright © 2016 BlurSoftware. All rights reserved.
//

import Cocoa

class RegionController: NSViewController {

    weak var pickerDelegate: RegionPickerObserver? {
        didSet {
            //Europe is the default region
            self.setSelectedRegion(.Europe)
        }
    }
    
    @IBOutlet weak var oceaniaButton: NSButton!
    @IBOutlet weak var europeButton: NSButton!
    @IBOutlet weak var americasButton: NSButton!
    @IBOutlet weak var asiaButton: NSButton!
    @IBOutlet weak var africaButton: NSButton!
    
    //TODO: This should be handled with a CollectionView or TableView, so we don't have all these IBActions

    @IBAction func onSelectAfrica(sender: AnyObject) {
        setSelectedRegion(.Africa)
    }
    
    @IBAction func onSelectEurope(sender: AnyObject) {
        setSelectedRegion(.Europe)
    }
    
    @IBAction func onSelectAmericas(sender: AnyObject) {
        setSelectedRegion(.America)
    }
    
    @IBAction func onSelectOceania(sender: AnyObject) {
        setSelectedRegion(.Oceania)
    }
    
    @IBAction func onSelectAsia(sender: AnyObject) {
        setSelectedRegion(.Asia)
    }
    
    func setSelectedRegion(region: Region) {
        switch region {
        case .Africa:
            oceaniaButton.state = NSOffState
            europeButton.state = NSOffState
            americasButton.state = NSOffState
            asiaButton.state = NSOffState
            africaButton.state = NSOnState
        case .America:
            oceaniaButton.state = NSOffState
            europeButton.state = NSOffState
            americasButton.state = NSOnState
            asiaButton.state = NSOffState
            africaButton.state = NSOffState
        case .Asia:
            oceaniaButton.state = NSOffState
            europeButton.state = NSOffState
            americasButton.state = NSOffState
            asiaButton.state = NSOnState
            africaButton.state = NSOffState
        case .Europe:
            oceaniaButton.state = NSOffState
            europeButton.state = NSOnState
            americasButton.state = NSOffState
            asiaButton.state = NSOffState
            africaButton.state = NSOffState
        case .Oceania:
            oceaniaButton.state = NSOnState
            europeButton.state = NSOffState
            americasButton.state = NSOffState
            asiaButton.state = NSOffState
            africaButton.state = NSOffState
        }
        
        pickerDelegate?.onRegionPicked(region)
    }
}

