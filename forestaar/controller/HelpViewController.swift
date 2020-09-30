//
//  TestViewController.swift
//  forestaar
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
        self.slides = [["label": "Welcome to ForestAR!, Press the camera icon on the home screen to get started.", "image": "Help_Main"],
                       ["label": "Scan your anchor image just by pointing your camera at it.", "image": "Help_Scanning"],
                       ["label": "If the view is too dark, click the light icon in the upper left corner to turn on your flashlight.", "image": "Help_Flash"],
                       ["label": "Your video will play on top of the image. Use the controls to interact, and favorite a video to easily come back to it later.”", "image":"Help_Playing"],
                       ["label": "If you have black spaces around the video, try rotating your device.  The video is automatically played in full screen if the image is out of view.", "image": "Help_Landscape"],
                       ["label": "Tap the link icon to open the website associated with the video.", "image": "Help_Webpage"],
                       ["label": "You can share your experience via social media or other sharing options on your device.", "image": "Help_Share"],
                       ["label": "Use the menu to access your favorites, how to guide, and contact information.", "image": "Help_Menu"],
                       ["label": "Access your favorites to easily get to your videos and websites. Swipe left to remove a favorite.", "image": "Help_Fav"]
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
//                scrollView.auk.show(url: s["image"]!)
                scrollView.auk.show(image: UIImage(named: s["image"]!)!)
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
