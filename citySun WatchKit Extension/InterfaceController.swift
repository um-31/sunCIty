//
//  InterfaceController.swift
//  citySun WatchKit Extension
//
//  Created by Udhay on 2020-08-24.
//  Copyright © 2020 Udhay. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController {
    
    var cityName = String()
    let session = WCSession.default
    
    @IBOutlet weak var cityLabel: WKInterfaceLabel!
    @IBOutlet weak var sunriseLabel: WKInterfaceLabel!
    @IBOutlet weak var sunsetLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func addCity() {
        self.presentTextInputController(withSuggestions: nil, allowedInputMode: .allowEmoji, completion: {
            results in
            
            guard let results = results else { return }
            OperationQueue.main.addOperation {
                self.dismissTextInputController()
                print("watch working")
                self.cityName = results[0] as! String
                print(self.cityName)
                let data: [String: Any] = ["watch": results[0] as Any]
                //Create your //dictionary as per uses
                if self.session.isCompanionAppInstalled {
                    print("app installed")
                    self.session.sendMessage(data, replyHandler: nil, errorHandler: nil)
                    NotificationCenter.default.post(name: .saveNotificationName, object: self.cityName)
                }else {
                    print("Not Installed")
                }
                
                
//                do{
//                    try self.session.updateApplicationContext(["iphone":self.cityName])
//                    print("here1")
//                }catch(let er){
//                    print(er)
//                    print("here2")
//                    }
                self.cityLabel.setText(results[0] as? String)
                print("here3")
            }
            
        })
    }
}

extension InterfaceController: WCSessionDelegate {
  
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
  }
  
  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    
    print("received data: \(message)")
    if let value = message["iPhone"] as? String {//**7.1
      self.sunsetLabel.setText("Sunset Time: \(value)")
    }
  }
}
