//
//  ViewController.swift
//  dashboard
//
//  Created by Adhikari, Bishrant on 10/16/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import UIKit
import SQLite3
//import Crashlytics

var serverURL: String = "https://txfipdev.tfs.tamu.edu/treeselector/"

class ViewController: UIViewController {
    var menuShowing = false
    @IBOutlet weak var sidemenu: UIView!
    @IBOutlet weak var LeadingConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (!Service.sharedInstance.getAppUpdateSuccess()){
            print("Error updating app")
        }
        TrailingConstraint.constant = 300;
        //showARDashboard();
//        showHelpPage();
//        showUserFavouritesPageFunc()
        showVideoPlayer()
//        showFavouritesPageFunc()
    }
    
    @IBAction func showARDashboard(_ sender: Any) {
        showARDashboard();
    }

    @IBAction func showHelpPageAction(_ sender: Any) {
        showHelpPage();
        toggleMenuFunc();
    }
    @IBOutlet weak var MenuBtn: UIButton!
    @IBOutlet weak var TrailingConstraint: NSLayoutConstraint!;
    
    private func toggleMenuFunc() {
        if(menuShowing) {
            TrailingConstraint.constant = 300;
        } else {
            TrailingConstraint.constant = 0
            UIView.animate(withDuration: 0.2,
                           delay:0,
                           options: .curveEaseIn,
                           animations: {
                self.view.layoutIfNeeded()
            });
            
        }
        menuShowing = !menuShowing
        MenuBtn.isHidden  = !MenuBtn.isHidden
    }
    @IBAction func toggleMenu(_ sender: Any) {
        toggleMenuFunc();
    }
    

    
    @IBAction func showFavouritesPage(_ sender: Any) {
        showUserFavouritesPageFunc()
//        showFavouritesPageFunc()
    }
    
    func showFavouritesPageFunc() {
        let storyboard = UIStoryboard(name: "Favourites", bundle: Bundle.main)
        let destination1 = storyboard.instantiateViewController(withIdentifier: "Favourites") as! FavouritesController
        navigationController?.pushViewController(destination1, animated: true)
    }
    
    func showVideoPlayer() {
        let storyboard = UIStoryboard(name: "VideoPlayer", bundle: Bundle.main)
        let destination1 = storyboard.instantiateViewController(withIdentifier: "VideoPlayer") as! VideoPlayerController
        navigationController?.pushViewController(destination1, animated: true)
    }
    
    func showUserFavouritesPageFunc() {
        let storyboard = UIStoryboard(name: "UserFavourites", bundle: Bundle.main)
        let destination1 = storyboard.instantiateViewController(withIdentifier: "UserFavourites") as! UserFavouritesController
        navigationController?.pushViewController(destination1, animated: true)
    }
    
    func showARDashboard() {
        let storyboard = UIStoryboard(name: "ARDashboard", bundle: Bundle.main)
        let destination1 = storyboard.instantiateViewController(withIdentifier: "ARDashboard") as! ARDashboardController
        navigationController?.pushViewController(destination1, animated: true)
    }
    
    func showHelpPage() {
        let storyboard = UIStoryboard(name: "Help", bundle: Bundle.main)
        let destination1 = storyboard.instantiateViewController(withIdentifier: "Help") as! HelpController
        navigationController?.pushViewController(destination1, animated: true)
    }

    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    @IBAction func insertIntoTable(_ sender: Any) {
//        self.database.insertIntoFavTable(name: randomString(length: 5), link: randomString(length: 5))
    }
    
    
}
