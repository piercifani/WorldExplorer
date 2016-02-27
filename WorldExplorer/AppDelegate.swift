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

    func applicationDidFinishLaunching(aNotification: NSNotification) {
    }

    func applicationDidBecomeActive(notification: NSNotification) {
        guard let rootVC = NSApplication.sharedApplication().mainWindow?.contentViewController as? NSSplitViewController else {
            return
        }
        
        guard let regionController = rootVC.splitViewItems[0].viewController as? RegionController else {
            return
        }
        
        regionController.apiClient = apiClient
        
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

}

