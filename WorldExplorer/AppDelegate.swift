//
//  AppDelegate.swift
//  WorldExplorer
//
//  Created by Pierluigi Cifani on 26/02/16.
//  Copyright © 2016 BlurSoftware. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let apiClient = APIClient()
    
    // I Hate this Bool, it adds state to this class and it's sloppy,
    // but I have no idea why appDidFinishLaunching and appDidBecomeActive
    // are being called either a lot, or before the view hierarchy is set up
    
    var setupFinished: Bool = false
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
    }
    
    func applicationDidBecomeActive(notification: NSNotification) {

        guard setupFinished == false else { return }
        
        guard let rootVC = NSApplication.sharedApplication().mainWindow?.contentViewController as? NSSplitViewController else {
            return
        }
        
        guard let regionController = rootVC.splitViewItems[0].viewController as? RegionController else {
            //Should this be a fatalError?
            return
        }

        guard let countryController = rootVC.splitViewItems[1].viewController as? CountryController else {
            //Should this be a fatalError?
            return
        }
        
        countryController.apiClient = apiClient
        regionController.pickerDelegate = countryController
        
        setupFinished = true
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

}

