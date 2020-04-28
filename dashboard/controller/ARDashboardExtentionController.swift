//
//  ARDashboardExtentionController.swift
//  dashboard
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
     
    
    func displayMessageInterface(message: String, imgName: String) {
             if MFMessageComposeViewController.canSendText() {
             let composeViewController = MFMessageComposeViewController()
             composeViewController.messageComposeDelegate = self
             composeViewController.body = message

             if MFMessageComposeViewController.canSendAttachments() {
                
                DispatchQueue.main.async {
                    if let data = try? Data(contentsOf: URL(string: serverURL + imgName + ".png")!) {
                              if let image = UIImage(data: data) {
                                                                     
                                    let dataImage =  image.pngData()
                                    guard dataImage != nil else {
                                        return
                                    }
                                    composeViewController.addAttachmentData(dataImage!, typeIdentifier: "image/png", filename: "ImageData.png")
                                  }
                        self.present(composeViewController, animated: true)
                              
                          }
                      }
                 
             }
             
         } else {
             print("Can't send messages.")
         }
     }
     
    func displayMailInterface(message: String) {
         if !MFMailComposeViewController.canSendMail() {
             print("Mail services are not available")
             return
         }
         let composeVC = MFMailComposeViewController()
         composeVC.mailComposeDelegate = self
          
         // Configure the fields of the interface.
         let strHtml = "<html><body>" + message + "<img src='https://via.placeholder.com/350'></b></p></body></html>"
         
         composeVC.mailComposeDelegate = self
         // Configure the fields of the interface.
         composeVC.setToRecipients(["address@example.com"])
         composeVC.setSubject("Hello!")
         composeVC.setMessageBody(strHtml, isHTML: true)
         
         self.present(composeVC, animated: true, completion: nil)
     }
     
//     @IBAction func showShareSheet(_ sender: UIButton) {
//            createShareActionBar(imageName: "tfsstar", description: "description")
//     }
//     
     func showFb() {
         print("show Fb")
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
        let appUpdate: AppUpdate = AppUpdate()
        let appInstalled = appUpdate.checkIfAppIsInstalled(name: "twitter")
        let message1 = message + " @TXForestService"
        let prefix = appInstalled ? "twitter://post?message=" : "https://twitter.com/intent/tweet?text="
        let fullUrl = prefix + message1.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.alphanumerics)!
        let appURL = NSURL(string: fullUrl)!
        UIApplication.shared.open(appURL as URL)
    }
    
    func createShareActionBar(imageName: String, message: String) {
         let actionController = SpotifyActionController()
         let titleImg = UIImage(named: "tfsstar")!
         
        actionController.headerData = SpotifyHeaderData(title: "Forest AR", subtitle: "Texas A&M Forest Service", image: titleImg)
        actionController.addAction(Action(ActionData(title: "  Facebook", image: UIImage(named: "facebook")!), style: .default, handler: { action in self.shareFb()}))
        actionController.addAction(Action(ActionData(title: "  Twitter", image: UIImage(named: "twitter")!), style: .default, handler: { action in self.shareTwitter(message: message)}))
        
        let appUpdate: AppUpdate = AppUpdate()
        if appUpdate.checkIfAppIsInstalled(name: "instagram") {
            actionController.addAction(Action(ActionData(title: "  Instagram", image: UIImage(named: "instagram")!), style: .default, handler: { action in }))
        }
        
        actionController.addAction(Action(ActionData(title: "  Message", image: UIImage(named: "email")!), style: .default, handler: { action in self.displayMessageInterface(message: message, imgName: imageName)}))
        actionController.addAction(Action(ActionData(title: "  Mail",  image: UIImage(named: "email")!), style: .default, handler: { action in self.displayMailInterface(message: message)}))
        actionController.addAction(Action(ActionData(title: "  More"), style: .default, handler: { action in self.showShareSheet(actionController: actionController)}))
         present(actionController, animated: true, completion: nil)
        
    }
    
    func showShareSheet(actionController: SpotifyActionController) {
//        actionController.dismiss(completion: () -> Void) {
//            print("The quick brown fox")
////            completion()
//        }
//        actionController.dismiss(completion: print(4))
        actionController.dismiss()
        
          let titleImg = UIImage(named: "tfsstar")!
         let vc = UIActivityViewController(activityItems: ["Text to share some details", titleImg], applicationActivities: [])
         
        if let popoverController = vc.popoverPresentationController {
            popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popoverController.sourceView = self.view
            popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }
        self.present(vc, animated: true, completion: nil)
     }
    
    func showShareUIFunc(completion: () -> ()) {
        print(2)
    }
}
