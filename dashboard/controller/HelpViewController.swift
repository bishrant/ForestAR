//
//  TestViewController.swift
//  dashboard
//
//  Created by Adhikari, Bishrant on 11/18/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import UIKit
import Auk

class HelpViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var pictureLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    private var urls: String = Service.sharedInstance.serverURL
    var slides = [["label": "Welcome !, Press the camera icon", "image": "HelpImages/Help1.jpg"]]
    func initSlides() {
        self.urls = self.urls+"/public/"
        self.slides = [["label": "Welcome to Forest AR!, Press the camera icon on the home screen to get started.", "image": self.urls + "HelpImages/Help1.jpg"],
                       
                       ["label": "Scan your anchor image just by pointing your camera at it.", "image": self.urls + "HelpImages/Help3.jpg"],
                       ["label": "Your video will play on top of the image. Use video controls to interact with it. Favorite a video so that you can easily come back to it later.", "image": self.urls + "HelpImages/Help4.jpg"],
                       ["label": "If you have black spaces on top and bottom, try rotating your device to view the video in full screen. The video is automatically played in full screen if the photo is out of view.", "image": self.urls + "HelpImages/Help7.jpg"],
                       ["label": "Tap the link icon to open the website associated with the image.", "image": self.urls + "HelpImages/Help5.jpg"],
                       ["label": "You can share the image via social media or other sharing options on your device.", "image": self.urls + "HelpImages/Help6.jpg"],
                       ["label": "Use the menu to access your favorites, how to guide, and contact information.", "image": self.urls + "HelpImages/Help2.jpg"],
                       ["label": "Access your favorites to easily get to your videos and websites. Swipe left to remove a favorite.", "image": self.urls + "HelpImages/Help8.jpg"]
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initSlides()
        let gradientView = GradientView(frame: self.view.bounds)
        self.view.insertSubview(gradientView, at: 0)
        
        pictureLabel.text = self.slides[0]["label"]
        scrollView.delegate = self
        scrollView.auk.settings.pageControl.marginToScrollViewBottom = -25
        scrollView.auk.settings.pageControl.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        do { autoreleasepool{
            for s in slides {
                scrollView.auk.show(url: s["image"]!)
            }
            }
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pictureLabel.text = self.slides[scrollView.auk.currentPageIndex!]["label"]
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func skipTutorial(_ sender: Any) {
        let transition = CATransition()
        transition.duration = 0.1
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.popViewController(animated: false)
    }
}
