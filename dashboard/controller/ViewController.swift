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
    var db: OpaquePointer?
    override func viewDidLoad() {
        super.viewDidLoad()
        TrailingConstraint.constant = 300;
        createDb();

        let button = UIButton(type: .roundedRect)
        button.frame = CGRect(x: 20, y: 50, width: 100, height: 30)
        button.setTitle("send test data", for: [])
        button.addTarget(self, action: #selector(self.crashButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(button)
        
        showARDashboard();
//        showHelpPage();
       // showFavouritesPageFunc()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func showARDashboard(_ sender: Any) {
        showARDashboard();
    }
    @IBAction func crashButtonTapped(_ sender: AnyObject) {

//        Crashlytics.sharedInstance().crash()
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
    
    func createDb() -> Void {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("TreeID.sqlite")
        
        //let su = FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
        //print(su, " success in filemanager")
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database");
        } else {
            print("database opened");
            createTable(db!)
        }
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
    func createTable(_ db: OpaquePointer) -> Void {
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Favourites (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, link TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        } else {
            print("table created");
        }
    }
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    @IBAction func insertIntoTable(_ sender: Any) {
        var stmt: OpaquePointer?
        let queryString = "INSERT INTO Favourites (name, link) VALUES (?, ?)"
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        // binding the parameters
        sqlite3_bind_text(stmt, 1, randomString(length: 5), -1, nil);
        sqlite3_bind_text(stmt, 2, randomString(length: 15), -1, nil);
        if sqlite3_step(stmt) != SQLITE_DONE {
            print("failed to insert");
        } else {
            print ("saved to db");
        }
    }

    @IBAction func getFavourites(_ sender: Any) {
        let queryString = "SELECT * FROM Favourites"
        
        //statement pointer
        var stmt:OpaquePointer?
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //traversing through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let name = String(cString: sqlite3_column_text(stmt, 1))
            let powerrank = String(cString: sqlite3_column_text(stmt, 2))
            
            print(id, name, powerrank)
        }
    }
    
    
}

