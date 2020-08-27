//
//  ViewController.swift
//  citySun
//
//  Created by Udhay on 2020-08-24.
//  Copyright © 2020 Udhay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import WatchConnectivity


class ViewController: UIViewController {
    var session: WCSession?
    
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureWatchKitSesstion()
        // Do any additional setup after loading the view.
        print("working")
//        NotificationCenter.default.addObserver(forName: .saveNotificationName, object: nil, queue: nil) { (notification) in
//            print("Working till here")
//            print(notification.object as! String)
//            self.cityLabel.text = notification.object as? String
//            self.buttonPressed(city: notification.object as! String)
//        }

        
    }
    
    func configureWatchKitSesstion() {
      
      if WCSession.isSupported() {
        session = WCSession.default
        session?.delegate = self
        session?.activate()
      }
    }

    

    
    func buttonPressed(city: String) {
        self.cityLabel.text = city
        print(city)
        let URLCity = "https://geocode.xyz/\(city)?json=1"
        Alamofire.request(URLCity).responseJSON {
            response in
            
            guard let apiDataCity = response.result.value else {
                print("Error getting data from the URL")
                return
            }
            
            let jsonResponseCity = JSON(apiDataCity)
            let longt = jsonResponseCity["longt"].string
            let latt = jsonResponseCity["latt"].string
            print("longt: \(longt!)")
            print("latt: \(latt!)")
            self.getSunValue(longt: longt!, latt: latt!)
        }
    }
    
    func getSunValue(longt: String, latt: String) {
        let URL = "https://api.sunrise-sunset.org/json?lat=\(latt)&lng=\(longt)&date=today"
        Alamofire.request(URL).responseJSON {
            // 1. store the data from the internet in the
            // response variable
            response in
            guard let apiData = response.result.value else {
                 print("Error getting data from the URL")
                 return
             }
             
            //print(apiData)
            
            let jsonResponse = JSON(apiData)
            let sunriseTime = jsonResponse["results"]["sunrise"].string
            let sunsetTime = jsonResponse["results"]["sunset"].string
            
            print("Sunrise: \(sunriseTime!)")
            print("Sunset: \(sunsetTime!)")
            self.sunriseLabel.text = "Sunrise: \(sunriseTime ?? "")"
            self.sunsetLabel.text = "Sunset: \(sunsetTime ?? "")"
            let sunData = [sunriseTime,sunsetTime]
            
//            if self.session!.isWatchAppInstalled {
//                print("Watch app is installed")
//                self.session?.sendMessage(data, replyHandler: nil, errorHandler: nil)
//            }
            print("working")
            NotificationCenter.default.post(name: .saveNotificationName, object: sunsetTime)
            if let validSession = self.session, validSession.isReachable {
                print("Sent")//5.1
                // Create your Dictionay as per uses
                let data: [String: Any] = ["iPhone": sunData as Any]
                validSession.sendMessage(data, replyHandler: nil, errorHandler: nil)
                
            }
        }
        
    }


}


extension ViewController: WCSessionDelegate {
  
  func sessionDidBecomeInactive(_ session: WCSession) {
  }
  
  func sessionDidDeactivate(_ session: WCSession) {
  }
  
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
  }
//    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
//        let data = applicationContext["iphone"] as? String
//        self.cityLabel.text = data!
//        self.buttonPressed(city: data!)
//    }
  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    print("received message: \(message)")
    DispatchQueue.main.async { //6
        print(message)
      if let value = message["watch"] as? String {
        self.cityLabel.text = value
        self.buttonPressed(city: value)
      }
    }
  }
}

