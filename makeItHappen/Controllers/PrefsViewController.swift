//
//  PrefsViewController.swift
//  makeItHappen
//
//  Created by CongminQiu on 6/8/18.
//  Copyright © 2018 CongminQiu. All rights reserved.
//

import Cocoa

class PrefsViewController: NSViewController {

    // this is a test
    var kShortCut: MASShortcut!
    var count:Int = 0
    
    @IBOutlet weak var contentLabel: NSTextField!
    @IBOutlet weak var showCount: NSTextField!
    @IBOutlet weak var shortcutView: MASShortcutView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        shortcutView.shortcutValueChange = { (sender) in
            
            let callback: (() -> Void)!
            
            if self.shortcutView.shortcutValue.keyCodeStringForKeyEquivalent == "k" {
                
                self.kShortCut = self.shortcutView.shortcutValue
                
                callback = {
                    print("K shortcut handler")
                }
            } else {
                callback = {
                    self.count = self.count + 1
                    print("Default handler")
                    self.showCount.stringValue = ((String)(self.count))
                    
                    let src = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
                    
                    let cmdd = CGEvent(keyboardEventSource: src, virtualKey: 0x38, keyDown: true)
                    let cmdu = CGEvent(keyboardEventSource: src, virtualKey: 0x38, keyDown: false)
                    let spad = CGEvent(keyboardEventSource: src, virtualKey: 0x00, keyDown: true)
                    let spau = CGEvent(keyboardEventSource: src, virtualKey: 0x00, keyDown: false)
                    let spcd = CGEvent(keyboardEventSource: src, virtualKey: 0x08, keyDown: true)
                    let spcu = CGEvent(keyboardEventSource: src, virtualKey: 0x08, keyDown: false)
                    
                    spcd?.flags = CGEventFlags.maskCommand;
                    
                    let loc = CGEventTapLocation.cghidEventTap
                    // command a
                    cmdd?.post(tap: loc)
                    spad?.post(tap: loc)
                    spau?.post(tap: loc)
                    cmdu?.post(tap: loc)
                    
                    // command c, copy selected content to clipboard
                    cmdd?.post(tap: loc)
                    spcd?.post(tap: loc)
                    spcu?.post(tap: loc)
                    cmdu?.post(tap: loc)
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) { // change 2 to desired number of seconds
                        // fetch content from clipboard
                        let pasteboard = NSPasteboard.general
                        let copiedString = pasteboard.string(forType:NSPasteboard.PasteboardType.string)
                        self.contentLabel.stringValue = copiedString!
                    }
                }
            }
            
            MASShortcutMonitor.shared().register(self.shortcutView.shortcutValue, withAction: callback)
        }
    }
    
    @IBAction func unregisterAllButtonClicked(sender: AnyObject) {
        
        MASShortcutMonitor.shared().unregisterAllShortcuts()
    }
    
    @IBAction func unregisterKShortCutButtonClicked(sender: AnyObject) {
        
        unregisterKShortCutIfNeeded()
    }
    
    func unregisterKShortCutIfNeeded() {
        
        guard let shortcut = kShortCut else {
            
            return
        }
        MASShortcutMonitor.shared().unregisterShortcut(shortcut)
    }
}
