//
//  IntermediateViewController.swift
//  COVID-19Hackathon
//
//  Created by Mishaal Kandapath on 4/13/20.
//  Copyright © 2020 Mishaal Kandapath. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase
import UserNotifications

class IntermediateViewController: UIViewController {
    @IBOutlet weak var enterbtn: UIButton!
    var seconds = 60*20
    var timer = Timer()
    var isTimerRunning = false
    var enterTapped = false
    var exitTapped = false
    var dataList = [String]()
    @IBOutlet weak var exitbtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewloading")
        exitbtn.layer.cornerRadius = 20
        enterbtn.layer.cornerRadius = 20
        exitbtn.layer.shadowColor = UIColor.black.cgColor
        exitbtn.layer.shadowOpacity = 0.8
        exitbtn.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        exitbtn.layer.shadowRadius = 3
        enterbtn.layer.shadowColor = UIColor.black.cgColor
        enterbtn.layer.shadowOpacity = 0.8
        enterbtn.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        enterbtn.layer.shadowRadius = 3
        let check = KeychainWrapper.standard.bool(forKey: "should")!
        print("check")
        if check{
            enterbtn.alpha = 1
            enterbtn.isUserInteractionEnabled = true
            exitbtn.alpha = 0
            exitbtn.isUserInteractionEnabled = false

        }else{
            enterbtn.alpha = 1
            enterbtn.isUserInteractionEnabled = true
            exitbtn.alpha = 0
            exitbtn.isUserInteractionEnabled = false
        }
        /*let group = DispatchGroup()
        group.enter()
        DispatchQueue.main.async {
            self.getInfectedInfo()
            group.leave()
        }*/
       
        // Do any additional setup after loading the view.
    }
    
    func getInfectedInfo(completion: @escaping (_ success: Bool) -> Void){
        Database.database().reference().child("infected").observeSingleEvent(of: .value) { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            for data in snapshot{
                let val = data.value
                print("val",val)
                if let peopleList = val as? Dictionary<String, Any>{
                    guard let people = peopleList["affectedList"] as? [Any] else {
                        print("nope list")
                        print(peopleList["affectedList"])
                        print(peopleList["affectedList"] as? [NSNumber] ?? "j")
                        return
                    }
                    for person in people{
                        self.dataList.append(String(describing: person))
                    }
                }else{
                    print("nope")
                }
            }
        }
        completion(true)
        
    }
    
    /*override func viewWillAppear(_ animated: Bool) {
        print("called")
    }*/
    
    override func viewDidAppear(_ animated: Bool) {
        let check = KeychainWrapper.standard.bool(forKey: "should")!
        print("check in appear")
        if check{
            enterbtn.alpha = 1
            enterbtn.isUserInteractionEnabled = true
            exitbtn.alpha = 0
            exitbtn.isUserInteractionEnabled = false
        }else{
            exitbtn.alpha = 1
            exitbtn.isUserInteractionEnabled = true
            enterbtn.alpha = 0
            enterbtn.isUserInteractionEnabled = false
        }
        getInfectedInfo { (success) in
                   print(success)
                   if success{
                       print("insir")
                       guard let bole = KeychainWrapper.standard.bool(forKey: "should") as? Bool else {return}
                       print(bole)
                       if (bole){
                           print("bam")
                           let adhn = KeychainWrapper.standard.string(forKey: "aadhar")
                           for person in self.dataList{
                               if person == adhn{
                                   print("ucud be infeced")
                                   break
                               }else{
                                   print("not infected")
                               }
                           }
                       }
                   }else{
                       print("oops")
                   }
               }
    }
    
    func runTimer() {
         timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
    }
    @objc func updateTimer() {
        seconds -= 1 //This will decrement(count down)the seconds.
        if seconds == 0{
            print("get out")
        }
    }
    
    @IBAction func toScan(_sender:Any){
        performSegue(withIdentifier: "toScanFinal", sender: nil)
    }

    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendNoti( _sender: Any){
        print("in")
        let content = UNMutableNotificationContent()
        content.title = "Time Limit"
        content.subtitle = "Hey! You have spent more than 20 mins here!"
        content.sound = UNNotificationSound.default

        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // add our notification request
        UNUserNotificationCenter.current().add(request)
        print("out")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
