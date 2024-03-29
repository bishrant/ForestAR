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


extension VideoPlayerController: MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate  {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    @IBAction func backButtonDidTouch(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    func displayMessageInterface(message: String, imageName: String, folderName: String, title: String) {
        if MFMessageComposeViewController.canSendText() {
            let composeViewController = MFMessageComposeViewController()
            composeViewController.messageComposeDelegate = self
            composeViewController.body = message
            
            if MFMessageComposeViewController.canSendAttachments() {
                
                DispatchQueue.main.async {
//                    let imgSplit = imgName.components(separatedBy: "___")
                    let imgURL = URL(string: Service.sharedInstance.serverURL + "public/" + folderName + "/" + imageName)
                    if let data = try? Data(contentsOf: imgURL!) {
                        if let image = UIImage(data: data) {
                            
                            let dataImage =  image.pngData()
                            guard dataImage != nil else {
                                return
                            }
                            composeViewController.addAttachmentData(dataImage!, typeIdentifier: "image/" + imgURL!.pathExtension , filename: imageName)
                        }
                        self.present(composeViewController, animated: true)
                        
                    }
                }
                
            }
            
        } else {
            print("Can't send messages.")
        }
    }
    
    func displayMailInterface(message: String, imageName: String, folderName: String, title: String) {
        if !MFMailComposeViewController.canSendMail() {
            let alert = UIAlertController(title: "Unable to compose mail", message: "It looks like your mail client is not configured yet. Please setup at least one email account to share ForestAR anchor details via email.", preferredStyle: .alert)
            print("Mail services are not available");
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true)
            return
        }

        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        let imgUrl = Service.sharedInstance.serverURL + "public/" + folderName + "/" + imageName
        // Configure the fields of the interface.
        let strHtml = "<html><body>" + message + "<br><img src='" + imgUrl + "' width='400px'></b></p></body></html>"
        
        composeVC.mailComposeDelegate = self
        // Configure the fields of the interface.
        composeVC.setSubject(title + " created using Forest AR")
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
    func showMsg() {
        let composeViewController = MFMessageComposeViewController()
//        composeViewController.messageComposeDelegate = self
        composeViewController.messageComposeDelegate = self;
        composeViewController.body = "TEST"
//        self.present(msgVC, animated: true);
        self.present(composeViewController, animated: false, completion: nil)
    }

    func favCreateShareActionBar(imageName: String, message: String, folderName: String, title: String) {
        let actionController = SpotifyActionController()
        let titleImg = UIImage(named: "tfsstar")!
        
        actionController.headerData = SpotifyHeaderData(title: "Forest AR", subtitle: "Texas A&M Forest Service", image: titleImg)
        actionController.addAction(Action(ActionData(title: "  Facebook", image: UIImage(named: "facebook")!), style: .default, handler: { action in self.shareFb()}))
        actionController.addAction(Action(ActionData(title: "  Twitter", image: UIImage(named: "twitter")!), style: .default, handler: { action in self.shareTwitter(message: message)}))
        
        if Service.sharedInstance.checkIfAppIsInstalled(name: "instagram") {
            actionController.addAction(Action(ActionData(title: "  Instagram", image: UIImage(named: "instagram")!), style: .default, handler: { action in }))
        }
        
        actionController.addAction(Action(ActionData(title: "  Message", image: UIImage(named: "message")!), style: .default, handler: { action in
                                            
                                            self.showMsg();
//                                            self.displayMessageInterface(message: message, imageName: imageName, folderName: folderName, title: title)
            
        }))
        actionController.addAction(Action(ActionData(title: "  Mail",  image: UIImage(named: "email")!), style: .default, handler: { action in self.displayMailInterface(message: message, imageName: imageName, folderName: folderName, title: title)}))
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
