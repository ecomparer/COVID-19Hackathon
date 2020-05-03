//
//  InfoPassViewController.swift
//  COVID-19Hackathon
//
//  Created by Mishaal Kandapath on 4/11/20.
//  Copyright © 2020 Mishaal Kandapath. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class InfoPassViewController: UIViewController {

    @IBOutlet weak var exitBtn: UIButton!
    @IBOutlet weak var goBtn: UIButton!
    @IBOutlet weak var placeField: UITextField!
    var date = Date()
    var changingId = ""
    var dataDictMain: [String:Any] = [:]
    let listMonth = ["January","February","March","April","May","June","July","August","September","October","November","December"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goBtn.layer.cornerRadius = 20
        exitBtn.layer.cornerRadius = 20
        let check = KeychainWrapper.standard.bool(forKey: "should")!
        if check{
            exitBtn.alpha = 0
            exitBtn.isUserInteractionEnabled = false
        }else{
            goBtn.alpha = 0
            goBtn.isUserInteractionEnabled = false
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func passInfo(_ sender: Any) {
        let adh = KeychainWrapper.standard.string(forKey: "aadhar")!
        var title = goBtn.titleLabel?.text as! String
        if goBtn.isUserInteractionEnabled {
            let fullname = KeychainWrapper.standard.string(forKey: "fullname")!
            //let adding = Database.database().reference().child(adh).childByAutoId()
            //changingId = adding.key as! String
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            let minute = calendar.component(.minute, from: date)
            let day = calendar.component(.day, from: date)
            let month = calendar.component(.month, from: date)
            print(month,day,hour,minute)
            let entry = Double(hour)+(Double(minute)/Double(100))
            dataDictMain = ["entry":entry] as [String : Any]
            KeychainWrapper.standard.set(entry, forKey: "entry")
            //adding.setValue(dataDict)
            goBtn.isUserInteractionEnabled = false
            goBtn.alpha = 0
            exitBtn.isUserInteractionEnabled = true
            exitBtn.alpha = 1
            KeychainWrapper.standard.set(false, forKey: "should")
            KeychainWrapper.standard.set(self.placeField.text!, forKey: "place")
        }else{
            let newcalendar = Calendar.current
            let hour = newcalendar.component(.hour, from: date)
            let minute = newcalendar.component(.minute, from: date)
            let day = newcalendar.component(.day, from: date)
            let month = newcalendar.component(.month, from: date)
            print(month,day,hour,minute)
            let monthWord = listMonth[month - 1]
            let dayStr = String(day)
            var dateInFormat = ""
            if month < 10 && day < 10{
                dateInFormat = "0"+String(month)+"-"+"0"+String(day)
            }else if month < 10 && day > 10{
                dateInFormat = "0"+String(month)+"-"+String(day)
            }else if month > 10 && day < 10{
                dateInFormat = String(month)+"-"+"0"+String(day)
            }else{
                dateInFormat = String(month)+"-"+String(day)
            }
            guard let place = KeychainWrapper.standard.string(forKey: "place") else {
                print("no key")
                return
            }
            let adding = Database.database().reference().child("Places").child(place).child(dateInFormat).child(adh)
            let exit = Double(hour)+(Double(minute)/Double(100))
            dataDictMain["exit"] = exit
            dataDictMain["entry"] = KeychainWrapper.standard.double(forKey: "entry")!
            adding.setValue(dataDictMain)
            goBtn.isUserInteractionEnabled = true
            goBtn.alpha = 1
            exitBtn.isUserInteractionEnabled = false
            exitBtn.alpha = 0
            KeychainWrapper.standard.set(false, forKey: "should")
        }
        performSegue(withIdentifier: "sample", sender: nil)
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
