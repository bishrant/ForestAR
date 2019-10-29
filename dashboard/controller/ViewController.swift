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


class ViewController: UIViewController {
    var menuShowing = false
    @IBOutlet weak var sidemenu: UIView!
    @IBOutlet weak var LeadingConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TrailingConstraint.constant = 300;
//        print(Service.sharedInstance.getAppVersion())
        
        //showARDashboard();
//        showHelpPage();
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
        showFavouritesPageFunc()
    }
    
    func showFavouritesPageFunc() {
        let storyboard = UIStoryboard(name: "Favourites", bundle: Bundle.main)
        let destination1 = storyboard.instantiateViewController(withIdentifier: "Favourites") as! FavouritesController
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

//    @IBAction func getFavourites(_ sender: Any) {
//        let queryString = "SELECT * FROM Favourites"
//
//        //statement pointer
//        var stmt:OpaquePointer?
//
//        //preparing the query
//        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
//            let errmsg = String(cString: sqlite3_errmsg(db)!)
//            print("error preparing insert: \(errmsg)")
//            return
//        }
//
//        //traversing through all the records
//        while(sqlite3_step(stmt) == SQLITE_ROW){
//            let id = sqlite3_column_int(stmt, 0)
//            let name = String(cString: sqlite3_column_text(stmt, 1))
//            let powerrank = String(cString: sqlite3_column_text(stmt, 2))
//
//            print(id, name, powerrank)
//        }
//    }
    
    
}

