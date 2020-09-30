//
//  ARDashboardExtentionController.swift
//  forestaar
//
//  Created by Adhikari, Bishrant on 12/5/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import UIKit
import Photos
import XLActionController
import MessageUI


extension ARDashboardController: MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate  {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    @IBAction func backButtonDidTouch(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func showMsg() {
        let composeViewController = MFMessageComposeViewController()
        composeViewController.messageComposeDelegate = self;
//        composeViewController.messageComposeDelegate = self
        composeViewController.messageComposeDelegate = self;
        composeViewController.body = "TEST"
//        self.present(msgVC, animated: true);
        self.present(composeViewController, animated: true, completion: nil)
    }
    
    func displayMessageInterface(message: String, imgName: String) {
        let composeViewController = MFMessageComposeViewController()
//        composeViewController.messageComposeDelegate = self
        composeViewController.messageComposeDelegate = self;
        composeViewController.body = message
//        self.present(msgVC, animated: true);
        self.present(composeViewController, animated: true, completion: nil)
//        return;

//
//        return;
//        self.showAlert()//(onView: self.view);
//        if MFMessageComposeViewController.canSendText() {
//            let composeViewController = MFMessageComposeViewController()
//            composeViewController.messageComposeDelegate = self
//            composeViewController.body = message
//            self.present(composeViewController, animated: true);
////            if MFMessageComposeViewController.canSendAttachments() {
////
////                DispatchQueue.main.async {
////
////                    let imgSplit = imgName.components(separatedBy: "___")
////                    let imgURL = URL(string: Service.sharedInstance.serverURL + "public/" + imgSplit[0] + "/" + imgSplit[1])
////                    if let data = try? Data(contentsOf: imgURL!) {
////                        if let image = UIImage(data: data) {
////
////                            let dataImage =  image.pngData()
////                            guard dataImage != nil else {
////                                return
////                            }
////                            composeViewController.addAttachmentData(dataImage!, typeIdentifier: "image/" + imgURL!.pathExtension , filename: imgSplit[1])
////                        }
////
////
////                    }
////                }
////
////            }
//
//        } else {
//            print("Can't send messages.")
//        }
    }
    
    func logImageScan(imageName: String) {
        DispatchQueue.global(qos: .background).async {
            let uuid = UIDevice.current.identifierForVendor?.uuidString;
            let url = Service.sharedInstance.serverURL + "updateScanLog";
            guard let serviceURL = URL(string: url) else {return}
            let session = URLSession.shared
            let parameters = [
                "imageName" : imageName,
                "deviceID": uuid
            ]
            var request = URLRequest(url: serviceURL)
            request.httpMethod = "POST"
            request.setValue("Application/JSON", forHTTPHeaderField: "Content-Type")
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            } catch let error {
                print(error.localizedDescription)
            }
            
            //create dataTask using the session object to send data to the server
            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                
                guard error == nil else {
                    return
                }
                
                guard let data = data else {
                    return
                }
                
                do {
                    //create json object from data
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        print(json)
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            })
            task.resume()
        }
        
    }
    
    func displayMailInterface(message: String, imageName: String) {
        if !MFMailComposeViewController.canSendMail() {
            let alert = UIAlertController(title: "Unable to compose mail", message: "It looks like your mail client is not configured yet. Please setup at least one email account to share ForestAR anchor details via email.", preferredStyle: .alert)
            print("Mail services are not available");
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true)
            return
        }
        let sql = SqliteDatabase()
        let imgData: ARImageEntry = sql.getDetailsUsingImageName(imageName: imageName)
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        let imgUrl = Service.sharedInstance.serverURL + "public/" + imgData.folderName + "/" + imgData.imageName
        // Configure the fields of the interface.
        let strHtml = "<html><body>" + message + "<br><img src='" + imgUrl + "' width='400px'></b></p></body></html>"
        
        composeVC.mailComposeDelegate = self
        // Configure the fields of the interface.
        //         composeVC.setToRecipients(["address@example.com"])
        composeVC.setSubject(imgData.title + " created using Forest AR")
        composeVC.setMessageBody(strHtml, isHTML: true)
        
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func shareFb() {
        let fbURLWeb: NSURL = NSURL(string: "https://www.facebook.com/sharer/sharer.php?u=http://texasforestinfo.tamu.edu/")!
        UIApplication.shared.open(fbURLWeb as URL)
    }
    
    @objc func imageInsta(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        if let lastAsset = fetchResult.firstObject {
            let url = URL(string: "instagram://library?LocalIdentifier=\(lastAsset.localIdentifier)")!
            UIApplication.shared.open(url)
        }
    }
    
    
    func shareInstagram(imgName: String) {
        let imageUtils = ImageUtils()
        let instaImage = imageUtils.getImageFromFileName(name: imgName)
        UIImageWriteToSavedPhotosAlbum(instaImage, self, #selector(imageInsta(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func shareTwitter(message: String) {
        let appInstalled = Service.sharedInstance.checkIfAppIsInstalled(name: "twitter")
        let message1 = message + " @TXForestService"
        let prefix = appInstalled ? "twitter://post?message=" : "https://twitter.com/intent/tweet?text="
        let fullUrl = prefix + message1.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.alphanumerics)!
        let appURL = NSURL(string: fullUrl)!
        UIApplication.shared.open(appURL as URL)
    }

    func createShareActionBar(imageName: String, message: String) {
//        self.test();
        let actionController = SpotifyActionController()
        let titleImg = UIImage(named: "tfsstar")!
        
        actionController.headerData = SpotifyHeaderData(title: "Forest AR", subtitle: "Texas A&M Forest Service", image: titleImg)
        actionController.addAction(Action(ActionData(title: "  Facebook", image: UIImage(named: "facebook")!), style: .default, handler: { action in self.shareFb()}))
        actionController.addAction(Action(ActionData(title: "  Twitter", image: UIImage(named: "twitter")!), style: .default, handler: { action in self.shareTwitter(message: message)}))
        
        if Service.sharedInstance.checkIfAppIsInstalled(name: "instagram") {
            actionController.addAction(Action(ActionData(title: "  Instagram", image: UIImage(named: "instagram")!), style: .default, handler: { action in }))
        }
        
        actionController.addAction(Action(
            
            ActionData(title: "  Message", image: UIImage(named: "message")!), style: .default,
            handler: {action in
                print("message");
//                self.showMsg();
//                self.test();
                                            
//                                            action in
                self.displayMessageInterface(message: message, imgName: imageName)
            
        }
        ))
        actionController.addAction(Action(ActionData(title: "  Mail",  image: UIImage(named: "email")!), style: .default, handler: { action in self.displayMailInterface(message: message, imageName: imageName)}))
        actionController.addAction(Action(ActionData(title: "  More"), style: .default, handler: { action in self.showShareSheet(actionController: actionController, message: message)}))
        present(actionController, animated: true, completion: nil)
        
    }
    
    func showShareSheet(actionController: SpotifyActionController, message: String) {
        actionController.dismiss()
        let titleImg = UIImage(named: "tfsstar")!
        let vc = UIActivityViewController(activityItems: [message, titleImg], applicationActivities: [])
        
        if let popoverController = vc.popoverPresentationController {
            popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popoverController.sourceView = self.view
            popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }
        self.present(vc, animated: true, completion: nil)
    }
}
