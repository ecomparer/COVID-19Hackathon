//
//  RegisterViewController.swift
//  COVID-19Hackathon
//
//  Created by Mishaal Kandapath on 4/11/20.
//  Copyright © 2020 Mishaal Kandapath. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class RegisterViewController: UIViewController {

    @IBOutlet weak var regBtn: UIButton!
    @IBOutlet weak var fullname: UITextField!
    @IBOutlet weak var adhField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        regBtn.layer.cornerRadius = 20
        regBtn.layer.shadowColor = UIColor.black.cgColor
        regBtn.layer.shadowOpacity = 0.8
        regBtn.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        regBtn.layer.shadowRadius = 3
        passwordField.layer.shadowColor = UIColor.black.cgColor
        passwordField.layer.shadowOpacity = 0.8
        passwordField.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        passwordField.layer.shadowRadius = 3
        emailField.layer.shadowColor = UIColor.black.cgColor
        emailField.layer.shadowOpacity = 0.8
        emailField.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        emailField.layer.shadowRadius = 3
        adhField.layer.shadowColor = UIColor.black.cgColor
        adhField.layer.shadowOpacity = 0.8
        adhField.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        adhField.layer.shadowRadius = 3
        fullname.layer.shadowColor = UIColor.black.cgColor
        fullname.layer.shadowOpacity = 0.8
        fullname.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        fullname.layer.shadowRadius = 3
        // Do any additional setup after loading the view.
    }
    
    func storeUserData(userId: String){
        let userData:[String: Any] = ["email": self.emailField.text,"aadharCard":self.adhField.text,"fullname":self.fullname.text]
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
        KeychainWrapper.standard.set(adhField.text!,forKey: "adhno")
        adding.setValue(userData)
        print("done")
    }
    
    @IBAction func regsiter(_ sender: Any) {
        if fullname.text != "" && passwordField.text != "" && adhField.text != "" && emailField.text != "" {
            let email = emailField.text; let password = passwordField.text
            Auth.auth().createUser(withEmail: email!, password: password!) { authResult, error in
                self.storeUserData(userId: (authResult?.user.uid)!)
            KeychainWrapper.standard.set((authResult?.user.uid)!, forKey: "useruid")
                KeychainWrapper.standard.set((self.emailField.text)!, forKey: "usermail")
            print("registered")
            KeychainWrapper.standard.set(true, forKey: "should")
            self.performSegue(withIdentifier: "fromRegScan", sender: nil)
        }
        }
    }
    
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
