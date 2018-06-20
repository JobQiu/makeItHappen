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
        loadUser()
        loadCommitment()
        self.dreamLabel.stringValue = self.user.dream
    }
    
    var user:User = User(account: "",password_md5: "",token: "",userId:0,dream:"")
    let userKey = "User"
    private func loadUser(){
        guard
            let data = UserDefaults.standard.object(forKey: userKey) as? Data,
            let userTemp = NSKeyedUnarchiver.unarchiveObject(with: data) as? User else{
                return
        }
        self.user = userTemp
    }
    
    private func loadCommitment(){
        var question:String = "test"
        var request = URLRequest(url: URL(string: self.user.homepage+"/api/getATask?userId="+String(self.user.userId))!)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                if data == nil{
                    return
                }
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print(json)
                if json.keys.contains("content"){
                    let content = json["content"] as! String
                    question = content
                    let userId = json["timeSpend"] as! String
                    let b:Int? = Int(userId)
                    DispatchQueue.main.async {
                        self.questionLabel.stringValue = content
                    }
                    //let userId = json["timeSpend"] as! String
                    //let b:Int? = Int(userId)
                }
            } catch {
                print("JSON Serialization error")
            }
        }).resume()
    }
}
