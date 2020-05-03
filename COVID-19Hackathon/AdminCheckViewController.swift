//
//  AdminCheckViewController.swift
//  COVID-19Hackathon
//
//  Created by Mishaal Kandapath on 4/11/20.
//  Copyright © 2020 Mishaal Kandapath. All rights reserved.
//

import UIKit
import Firebase

class AdminCheckViewController: UIViewController {


    @IBOutlet weak var pssField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var incorrect: UILabel!
    @IBOutlet weak var goBtn: UIButton!
    @IBOutlet weak var daysField : UITextField!
    @IBOutlet weak var adhn: UITextField!
    var placesVisited = [String: Any]()
    var date = Date()
    let listMonth = ["January","February","March","April","May","June","July","August","September","October","November","December"]
    let no31 = [0,2,4,6,7,9,11]
    let no30 = [3,5,8,10]
    override func viewDidLoad() {
        super.viewDidLoad()
        incorrect.alpha = 0
        goBtn.layer.cornerRadius = 20

        // Do any additional setup after loading the view.
    }
    
    @IBAction func goBtnGo(_ sender: Any) {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        print("checking time",month,day,hour,minute)
        var i=0
        var listDays = [String:Any]()
        var thisMonth = [Int]()
        var lastMonth = [Int]()
        let nowMonth = listMonth[month - 1]
        let prevMonth = listMonth[month - 2]
        let index = month - 2
        var fro31 = 31
        var for30 = 30
        var feb = 28
        while i<7{
            var x = day - i
            if x>0{
                thisMonth.append(x)
            }else{
                if self.no31.contains(index){
                    fro31 -= 1
                    x = fro31
                }else if index == 1{
                    for30 -= 1
                    x=for30
                }else{
                    feb -= 1
                    x=feb
                }
                lastMonth.append(x)
            }
        }
        listDays[nowMonth] = thisMonth
        listDays[prevMonth] = lastMonth
        if emailField.text == "testuser@admin.com" && pssField.text == "adminadmin" {
            var adhno = adhn.text as! String
            var days = daysField.text as! String
            for i in thisMonth{
                let x = String(i)
                Database.database().reference().child(adhno).child(nowMonth).child(x).observeSingleEvent(of: .value) { (snapshot) in
                guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                    print("didnt go anywhere on ",x)
                    return
                    }
                var dataList = [String: Any]()
                for data in snapshot.reversed() {
                    guard let keyMain = data.key as? String else {
                        print("something happened")
                        return
                    }
                    Database.database().reference().child(adhno).child(nowMonth).child(x).observeSingleEvent(of: .value) { (snapshot1) in
                        guard let snapshot1 = snapshot1.children.allObjects as? [DataSnapshot] else {return}
                        for data in snapshot1{
                            //uard let placeDict = data.value as? Dictionary<String,AnyObject> else {return}
                            let place = data.key as! String
                            Database.database().reference().child(adhno).child(nowMonth).child(x).child(keyMain).child(place).observeSingleEvent(of: .value) { (snapshot2) in
                                guard let snapshot2 = snapshot2.children.allObjects as? [DataSnapshot] else {return}
                                for data in snapshot2.reversed(){
                                    print(data)
                                }
                            }
                        }
                    }
                   //
                }
                }
            }
        }else{
            self.incorrect.alpha = 1
        }
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
