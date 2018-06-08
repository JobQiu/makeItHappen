//
//  MainMenuController.swift
//  makeItHappen
//
//  Created by CongminQiu on 6/8/18.
//  Copyright © 2018 CongminQiu. All rights reserved.
//

import Cocoa
import Foundation

class MainMenuController: NSObject , NetServiceBrowserDelegate, NetServiceDelegate, NSMenuDelegate, PrefsWindowDelegate {
    
    @IBOutlet weak var statusMenu: NSMenu!
    
    let debugOutput = false
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength);
    
    var aboutWindow: AboutWindow!
    var mycommitment: MyCommitment!
    var prefsWindow: PrefsWindow!
    
    
    var numStaticMenuItems = 0;
    let headerMenuItems = 1;
    var menuIsOpen = false;
    
    var pendingResolves = 0;
    
    override func awakeFromNib() {
        // Initialize the application
        // - status bar item
        updateIcon()
        statusItem.menu = statusMenu
        numStaticMenuItems = statusMenu.items.count
        refreshMenu() // make sure we display the "no bonjour found" item until bonjour finds something for the first time
        // - about window
        aboutWindow = AboutWindow()
        mycommitment = MyCommitment()
        // - prefs window
        prefsWindow = PrefsWindow()
        prefsWindow.delegate = self
    }
    
    func updateOpStatus() {
    }
    
    
    // MARK: ==== NSMenuDelegate
    
    func menuWillOpen(_ menu: NSMenu) {
        
        updateOpStatus();
        menuIsOpen = true;
    }
    
    func menuDidClose(_ menu: NSMenu) {
        menuIsOpen = false;
    }
    
    
    // MARK: ==== NetServiceBrowser delegate
    
    func netServiceBrowser(_: NetServiceBrowser , didFind service: NetService, moreComing: Bool) {
        if debugOutput { print("didFind '\(service.name)', domain:\(service.domain), hostname:\(service.hostName ?? "<none>") - \(moreComing ? "more coming" : "all done")") }
        pendingResolves += 1
        if !moreComing {
            refreshMenu()
        }
    }
    
    func netServiceBrowser(_:NetServiceBrowser, didRemove service: NetService, moreComing: Bool)
    {
        if debugOutput { print("didRemove '\(service.name)' domain:\(service.domain), hostname:\(service.hostName ?? "<none>") - \(moreComing ? "more coming" : "all done")") }
        if !moreComing {
            refreshMenu()
        }
    }
    
    
    func netServiceBrowserWillSearch(_:NetServiceBrowser) {
        // Tells the delegate that a search is commencing.
        if debugOutput { print("netServiceBrowserWillSearch") }
    }
    
    func netServiceBrowser(_:NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        // Tells the delegate that a search was not successful.
        print("netServiceBrowser didNotSearch:\(errorDict)")
    }
    
    func netServiceBrowserDidStopSearch(_:NetServiceBrowser) {
        // Tells the delegate that a search was stopped.
        if debugOutput { print("netServiceBrowserDidStopSearch") }
    }
    
    // MARK: ==== NetServiceBrowser delegate
    
    func netServiceDidResolveAddress(_ service: NetService) {
        if debugOutput { print("netService '\(service.name)' DidResolveAddress hostname:\(service.hostName ?? "<none>")") }
        pendingResolves -= 1
        if pendingResolves <= 0 {
            refreshMenu()
            pendingResolves = 0
        }
    }
    
    
    func netService(_ service: NetService, didNotResolve errorDict: [String : NSNumber])
    {
        if debugOutput { print("netService '\(service.name)' didNotResolve error:\(errorDict)") }
        if pendingResolves <= 0 {
            refreshMenu()
            pendingResolves = 0
        }
    }
    
    
    // MARK: ==== Updating Menu
    
    func refreshMenu() {
        
        // remove the previous menu items
        for _ in 0..<statusMenu.items.count-numStaticMenuItems {
            statusMenu.removeItem(at: headerMenuItems)
        }
    }
    
    
    // MARK: ==== Handling menu actions
    
    @objc func localSiteMenuItemSelected(_ sender:Any) {
        if let item = sender as? NSMenuItem, let service = item.representedObject as? NetService {
            if debugOutput { print("- '\(service.name)'    -    '\(service.hostName ?? "<none>")'") }
            if let hoststring = service.hostName {
                // check for path
                var path = ""
                if let txtData = service.txtRecordData() {
                    let txtRecords = NetService.dictionary(fromTXTRecord: txtData)
                    if let pathData = txtRecords["path"], let pathStr = String(data:pathData, encoding: .utf8) {
                        path = pathStr
                        if (path.first ?? "/") != "/" {
                            path.insert("/", at: path.startIndex)
                        }
                    }
                }
                // check for dot at end of hostName
                var hostname = hoststring
                if (hostname.last ?? "_") == "." {
                    hostname.remove(at: hostname.index(before: hostname.endIndex))
                }
            }
        }
    }
    
    // MARK: ==== prefs changes
    
    
    func prefsDidUpdate() {
        updateIcon()
    }
    
    func updateIcon() {
        let defaults = UserDefaults.standard
        let monochrome = defaults.bool(forKey: "monochromeIcon")
        let icon = NSImage(named: NSImage.Name(rawValue: "statusIcon"))
        icon?.isTemplate = monochrome
        statusItem.image = icon
    }
    
    
    // MARK: ==== UI handlers
    
    @IBAction func quitChosen(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func aboutChosen(_ sender: NSMenuItem) {
        aboutWindow.showWindow(nil)
    }
    
    @IBAction func prefsChosen(_ sender: NSMenuItem) {
        prefsWindow.showWindow(nil)
    }
    
    @IBAction func openHomepage(_ sender: NSMenuItem) {
        mycommitment.showWindow(nil)
    }
    
}


