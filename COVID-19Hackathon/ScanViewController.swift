//
//  ScanViewController.swift
//  COVID-19Hackathon
//
//  Created by Mishaal Kandapath on 4/11/20.
//  Copyright © 2020 Mishaal Kandapath. All rights reserved.
//

import AVFoundation
import UIKit
import Firebase
import SwiftKeychainWrapper

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    let date = Date()
    var dataDictMain = [String: Any]()
    var scannon = true
    var changingId = ""
     let listMonth = ["January","February","March","April","May","June","July","August","September","October","November","December"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }

        dismiss(animated: true)
    }

    func found(code: String) {
        print(code)
        
        /*let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        print(month,day,hour,minute)
        let adh = KeychainWrapper.standard.string(forKey: "aadhar")!
        if scannon {
            let fullname = KeychainWrapper.standard.string(forKey: "fullname")!
            let entry = ["hour":hour,"minute":minute]
            dataDictMain = ["entry":entry] as [String : Any]
            scannon = false
        }else{
            let monthWord = listMonth[month - 1]
            let dayStr = String(day)
            let adding = Database.database().reference().child(adh).child(monthWord).child(dayStr).childByAutoId().child(code)
            let exit = ["hour":hour,"minute":minute]
            dataDictMain["exit"] = exit
            adding.setValue(dataDictMain)
            scannon = true
        }*/
        let adh = KeychainWrapper.standard.string(forKey: "aadhar")!
        let check = KeychainWrapper.standard.bool(forKey: "should")!
        if check {
            print("t is check")
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
            print("entry: ",entry)
            dataDictMain = ["entry":entry] as [String : Any]
            KeychainWrapper.standard.set(entry, forKey: "entry")
            //adding.setValue(dataDict)
            KeychainWrapper.standard.set(false, forKey: "should")
            KeychainWrapper.standard.set(code, forKey: "place")
            print("atif",KeychainWrapper.standard.bool(forKey: "should"))
        }else{
            print("it is not check")
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
            KeychainWrapper.standard.set(true, forKey: "should")
            print("atelse",KeychainWrapper.standard.bool(forKey: "should"))
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
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
