//
//  ViewController.swift
//  COVID-19Hackathon
//
//  Created by Mishaal Kandapath on 4/11/20.
//  Copyright © 2020 Mishaal Kandapath. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import WhatsNewKit
class ViewController: UIViewController {

    @IBOutlet weak var incorrect: UILabel!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var goBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        goBtn.layer.cornerRadius = 20
        goBtn.layer.shadowColor = UIColor.black.cgColor
        goBtn.layer.shadowOpacity = 0.8
        goBtn.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        goBtn.layer.shadowRadius = 3
        incorrect.alpha = 0
        emailField.layer.shadowColor = UIColor.black.cgColor
        passwordField.layer.shadowColor = UIColor.black.cgColor
        passwordField.layer.shadowOpacity = 0.8
        passwordField.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        passwordField.layer.shadowRadius = 3
        emailField.layer.shadowOpacity = 0.8
        emailField.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        emailField.layer.shadowRadius = 3
        // Do any additional setup after loading the view.
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        whatsNewIfNeeded()
    }
    
    func whatsNewIfNeeded(){
        print("in")

        let darkPurple = WhatsNewViewController.Configuration(
            theme: .darkPurple
        )
        
        /*let myTheme = WhatsNewViewController.Theme { configuration in
            configuration.backgroundColor = .white
            configuration.titleView.titleColor = .systemIndigo
            configuration.itemsView.titleFont = .systemFont(ofSize: 25)
            configuration.titleView.titleFont = .systemFont(ofSize: 45, weight: .bold)
            configuration.itemsView.titleColor = .systemIndigo
            configuration.detailButton?.titleColor = .systemIndigo
            configuration.completionButton.backgroundColor = .systemIndigo
            configuration.itemsView.subtitleColor = .darkGray
            // ...
        }*/
        
        var configuration = WhatsNewViewController.Configuration(
            theme: .darkLightBlue
        )
        //configuration.apply(theme: .darkPurple)
        configuration.itemsView.contentMode = .fill
        configuration.apply(animation: .slideDown)
        configuration.titleView.secondaryColor = .init(
            // The start index
            startIndex: 0,
            // The length of characters
            length: 6,
            // The secondary color to apply
            color: .whatsNewKitLightBlue
        )
        
        let whatsNew = WhatsNew(
            // The Title
            title: "How to Use",
            // The features you want to showcase
            items: [
                WhatsNew.Item(
                    title: "Sign Up or Make an Account",
                    subtitle: "Sign in using an email account or register with your aadhar card number and email.",
                    image: UIImage(named: "man")
                ),
                WhatsNew.Item(
                    title: "Hit Enter",
                    subtitle: "When entering a place hit enter to scan its barcode",
                    image: UIImage(named: "entry")
                ),
                WhatsNew.Item(
                    title: "Exit",
                    subtitle: "Hit exit when you leave the place and scan its barcode again ",
                    image: UIImage(named: "exit")
                ),
                WhatsNew.Item(
                    title: "Staying there for long?",
                    subtitle: "To remind you about your safety, you will recieve an alert for every 20 mins you stay in a place.",
                    image: UIImage(named: "safe")
                )
                ]
        )
        
        let keyValueVersionStore = KeyValueWhatsNewVersionStore(keyValueable: UserDefaults.standard)
        let whatsNewViewController = WhatsNewViewController(
            whatsNew: whatsNew,
            configuration: configuration,
            versionStore: keyValueVersionStore
        )
        if let vc = whatsNewViewController{
            self.present(vc, animated: true)
        }
        

    }
    
    /*func storeUserData(userId: String){
        let userData:[String: Any] = ["email": self.emailField.text]
        print(userData)
        let mail = self.emailField.text as! String
        var newMail = ""
        var x = ""
        for i in mail{
            if i=="."{
                x=">"
            }else{
                x = String(i)
            }
            newMail+=x
        }
        print(newMail,"modified")
        let adding = Database.database().reference().child("users").child(newMail)
        KeychainWrapper.standard.set(newMail, forKey: "newMail")
        adding.setValue(userData)
        print("done")
    }*/

    @IBAction func goReg(_ sender: Any) {
        performSegue(withIdentifier: "forNow", sender: nil)
    }
    
    @IBAction func gotoScan(_ sender: Any) {
        print("pressed")
        if emailField.text != "" && passwordField.text != ""{
            let email = emailField.text as! String
            let password = passwordField.text as! String
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
              guard let strongSelf = self else { return }
                if error != nil && !((self?.emailField.text?.isEmpty)!) {
                    //create account
                    print(error)
                    self!.incorrect.alpha = 1
                    print("error")
                }else{
                    print("account there")
                    if let userId = authResult?.user.uid{
                        KeychainWrapper.standard.set((authResult?.user.uid)!, forKey: "useruid")
                        let mail = self?.emailField.text!
                        var newMail = ""
                        var x = ""
                        for i in mail!{
                            if i=="."{
                                x=">"
                            }else{
                                x = String(i)
                            }
                            newMail+=x
                        }
                        print(newMail,"modified at sign")
                        KeychainWrapper.standard.set(newMail, forKey: "newMail")
                        KeychainWrapper.standard.set((self?.emailField.text)!, forKey: "usermail")
                        print("signed in")
                        Database.database().reference().child("users").child(newMail).observeSingleEvent(of: .value) { (snapshot) in
                            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
                            var dataList = [String: String]()
                            for data in snapshot.reversed() {
                                let key = data.key as! String
                                let value = data.value as! String
                                dataList[key] = value
                                print(data,key,value,dataList)
                            }
                            KeychainWrapper.standard.set(dataList["fullname"]!, forKey: "fullname")
                            KeychainWrapper.standard.set(dataList["aadharCard"]!,forKey: "aadhar")
                        }
                    }
                    KeychainWrapper.standard.set(true, forKey: "should")
                    self!.performSegue(withIdentifier: "toScan", sender: nil)
                    }
                }
        }else{
            incorrect.alpha = 1
            print("nil val")
        }
    }
}

