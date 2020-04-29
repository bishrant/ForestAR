//
//  TestViewController.swift
//  dashboard
//
//  Created by Adhikari, Bishrant on 11/18/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import UIKit
import Auk

class TutorialViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var skipBtn: UIBarButtonItem!
    
    @IBOutlet weak var pictureLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    private var urls = Service.sharedInstance.serverURL
    var slides = [["label": "Welcome !, Press the camera icon", "image": "HelpImages/Help1.jpg"]]
    func initSlides() {
        self.urls = self.urls+"/public/"
        self.slides =
            [["label": "Welcome to Forest AR, Let's get you started", "image": self.urls + "HelpImages/Help1.jpg"],
             ["label": "Use menu to access favorites, quick help and contact TFS", "image": self.urls + "HelpImages/Help2.jpg"],
             ["label": "Camera icon from homepage takes you to the scanning pages. Scan your anchor image just by pointing your camera at it", "image": self.urls + "HelpImages/Help3.jpg"],
             ["label": "Your video will start to play right where the photo was. Use video controls to interact with it. Favorite a video so that you can easily come back at it later.", "image": self.urls + "HelpImages/Help4.jpg"],
             ["label": "If you have black spaces on top/bottom try rotating your device to view in full screen. Video is played full screen if the photo is not in view frame.", "image": self.urls + "HelpImages/Help7.jpg"],
             ["label": "Use link icon to open website of the tracked photograph", "image": self.urls + "HelpImages/Help5.jpg"],
             ["label": "You can share this image and app in your social media or any other medium that you choose", "image": self.urls + "HelpImages/Help6.jpg"],
             ["label": "You can access your favorites to easily get to your video and websites. Swipe from right to delete.", "image": self.urls + "HelpImages/Help8.jpg"]
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initSlides()
        skipBtn.title = "Skip"
        pictureLabel.text = self.slides[0]["label"]
        scrollView.delegate = self
        do { autoreleasepool{
            for s in slides {
                scrollView.auk.show(url: s["image"]!)
            }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pictureLabel.text = self.slides[scrollView.auk.currentPageIndex!]["label"]
        if (slides.count - scrollView.auk.currentPageIndex! ==   1) {
            skipBtn.title = "Done"
        } else {
            skipBtn.title = "Skip"
        }
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
