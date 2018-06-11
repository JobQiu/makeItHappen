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
    // this is a test
    var kShortCut: MASShortcut!
    var count:Int = 0
    var user:User = User(account: "",password_md5: "",token: "")
    var preferences = Preferences(keyloggerLocation: "/Users/"+NSUserName()+"/Documents/keyloggertest/", startAtLogin: false)
    
    @IBOutlet weak var contentLabel: NSTextField!
    @IBOutlet weak var showCount: NSTextField!
    @IBOutlet weak var shortcutView: MASShortcutView!
    @IBOutlet weak var loginButton: NSButton!
    
    override var windowNibName : NSNib.Name! {
        return NSNib.Name(rawValue: "PrefsWindow")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        loadUser()
        loadPreferences()
        
        self.logLocation.stringValue = self.preferences.keyloggerLocation
        print(self.preferences.startAtLogin)
        if self.preferences.startAtLogin{
            self.startAtLogin.state = NSControl.StateValue.on
        }else{
            self.startAtLogin.state = NSControl.StateValue.off
        }
        
        if self.user.token != ""{
            self.loginFeedback.stringValue = "Logged-in, current user "+self.user.account
            self.loginButton.title="Re-Login"
        }
        
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        shortcutView.shortcutValueChange = { (sender) in
            
            let callback: (() -> Void)!
            print("short cut"+self.shortcutView.shortcutValue.keyCodeStringForKeyEquivalent)
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
                    //cmdd?.post(tap: loc)
                    //spad?.post(tap: loc)
                    //spau?.post(tap: loc)
                    //cmdu?.post(tap: loc)
                    
                    // command c, copy selected content to clipboard
                    //cmdd?.post(tap: loc)
                    //spcd?.post(tap: loc)
                    //spcu?.post(tap: loc)
                    //ngcmdu?.post(tap: loc)
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) { // change 2 to desired number of seconds
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
    
    func windowWillClose(_ notification: Notification) {
        
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
    
    @IBOutlet weak var loginFeedback: NSTextField!
    @IBOutlet weak var account: NSTextField!
    @IBOutlet weak var password: NSSecureTextField!
    
    @IBAction func login(_ sender: Any) {
        let account = self.account.stringValue
        let password_md5 = md5ify(original: self.password.stringValue)
        var request = URLRequest(url: URL(string: "http://127.0.0.1:8081/api/getToken?account="+account+"&password="+password_md5)!)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                if data == nil{
                    return
                }
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print(json)
                if json.keys.contains("token"){
                    let token = json["token"] as! String
                    self.loginFeedback.stringValue = token
                    self.saveUser(user: User(account: account,password_md5: password_md5,token: token))
                }
            } catch {
                print("JSON Serialization error")
            }
        }).resume()
        
    }
    
    
    let userKey = "User"
    let prefKey = "Pref"
    
    private func saveUser(user: User){
        let data = NSKeyedArchiver.archivedData(withRootObject: user)
        UserDefaults.standard.set(data, forKey: userKey)
    }
    
    private func savePref(pref: Preferences){
        let data = NSKeyedArchiver.archivedData(withRootObject: pref)
        UserDefaults.standard.set(data, forKey: prefKey)
    }
    
    private func loadUser(){
        guard
            let data = UserDefaults.standard.object(forKey: userKey) as? Data,
            let userTemp = NSKeyedUnarchiver.unarchiveObject(with: data) as? User else{
                return
        }
        self.user = userTemp
    }
    
    private func loadPreferences(){
        guard
            let data = UserDefaults.standard.object(forKey: prefKey) as? Data,
            let prefTemp = NSKeyedUnarchiver.unarchiveObject(with: data) as? Preferences else{
                return
        }
        self.preferences = prefTemp
    }
    
    private func md5ify(original:String)->String{
        return original
    }
    
    @IBOutlet weak var logLocation: NSTextField!
    
    @IBOutlet weak var startAtLogin: NSButton!
    
    
    @IBAction func savePreferences(_ sender: Any) {
        self.preferences.keyloggerLocation = self.logLocation.stringValue
        self.preferences.startAtLogin = Bool(startAtLogin.state == NSControl.StateValue.on)
        print(self.preferences.startAtLogin)
        savePref(pref: self.preferences)
        
    }
    
}


