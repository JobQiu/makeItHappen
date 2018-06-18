//
//  MyCommitment.swift
//  makeItHappen
//
//  Created by CongminQiu on 6/8/18.
//  Copyright © 2018 CongminQiu. All rights reserved.
//

import Cocoa

class MyCommitment: NSWindowController {
    
    @IBOutlet weak var doneTaskLabel: NSTextField!
    @IBOutlet weak var totalTaskLabel: NSTextField!
    
    @IBOutlet weak var dreamLabel: NSTextField!
    @IBOutlet weak var questionLabel: NSTextField!
    
    @IBOutlet weak var timeLabel: NSTextField!
    
   
    @IBAction func refreshAction(_ sender: Any) {
    }
    
    @IBAction func unpinAction(_ sender: Any) {
    }
    
    @IBAction func doneAction(_ sender: Any) {
    }
    override var windowNibName : NSNib.Name! {
        return NSNib.Name(rawValue: "MyCommitment")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.level = .floating
        window!.styleMask.remove(.resizable)
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
}
