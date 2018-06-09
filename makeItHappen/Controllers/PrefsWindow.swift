//
//  PrefsWindow.swift
//  LocalSites
//
//  Created by Lukas Zeller on 13.10.17.
//  Copyright © 2017 plan44.ch. All rights reserved.
//

import Cocoa
import AppKit

protocol PrefsWindowDelegate {
    func prefsDidUpdate()
}

class PrefsWindow: NSWindowController, NSWindowDelegate {
    
    var delegate: PrefsWindowDelegate?
    
    override var windowNibName : NSNib.Name! {
        return NSNib.Name(rawValue: "PrefsWindow")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
    }
    
    func windowWillClose(_ notification: Notification) {
        
    }
    
}

