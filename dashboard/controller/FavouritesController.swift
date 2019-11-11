//
//  FavouritesController.swift
//  dashboard
//
//  Created by Adhikari, Bishrant on 10/18/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import UIKit
import SQLite3


class FavouritesController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var SqliteDb = SqliteDatabase()
    var favouritesList = [FavouritesStruct] ()
    @IBOutlet weak var favTableView: UITableView!
    @IBOutlet weak var verticalStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.favTableView.backgroundColor = UIColor.white
        getAllFavourites();
        newPad()
    }
    
    private func getAllFavourites() {
        if SqliteDb.openDB() {
            self.favouritesList = SqliteDb.getFavourites();
        }
    }
    @IBAction func goBack(_ sender: Any) {
       navigationController?.popViewController(animated: true)
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favouritesList.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let fav = favouritesList[indexPath.row]
        let cell = FavouriteTableCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40), title: fav.name!, id: fav.id, photo: fav.photo!, video: fav.video!)
        cell.cellLabel.text = favouritesList[indexPath.row].name!
        cell.cellButton.name = favouritesList[indexPath.row].name!
        cell.cellButton.id = favouritesList[indexPath.row].id
        cell.cellButton.addTarget(self, action: #selector(deleteFav), for: .touchUpInside)
        cell.contentView.backgroundColor = UIColor.white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath) as! FavouriteTableCell
        
        let storyboard = UIStoryboard(name: "PlayFavVideo", bundle: Bundle.main)
        let destination1 = storyboard.instantiateViewController(withIdentifier: "PlayFavVideo") as! PlayFavVideoController
        destination1.id = currentCell.cellButton.id
        navigationController?.pushViewController(destination1, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completionHandler) in
            print("index path of delete: \(indexPath)")
            completionHandler(true)
        }

        let swipeActionConfig = UISwipeActionsConfiguration(actions: [delete])
        swipeActionConfig.performsFirstActionWithFullSwipe = false
        return swipeActionConfig
    }
    
    @objc func deleteFav(sender: FavouriteDeleteBtn) {
        let deleteSuccess = SqliteDb.deleteFavEntryByPhotoName(photoName: sender.photo);
        if deleteSuccess {
            self.favouritesList = SqliteDb.getFavourites();
            self.favTableView.reloadData();
            DispatchQueue.main.async { self.favTableView.reloadData() }
        }
    }
    
    func newPad() {
//        let keyPadWindow = UIScrollView(frame: CGRect(x: 0, y: 150, width: self.view.frame.width, height: self.view.frame.height - 150))
//        keyPadWindow.backgroundColor  = UIColor.red
//        var keyCount = 0
//        let keyPadSV = UIStackView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 100))
//        keyPadSV.axis = .vertical
//        keyPadSV.spacing = 0.0
//        keyPadSV.alignment = .center
//        keyPadSV.distribution = .equalSpacing
//        keyPadSV.backgroundColor = UIColor.orange
////        for k2s in 0...5 {
////            let keyPadSVB = UIStackView(frame:CGRect(x: 0, y: 0, width: 0, height: 0))
////            keyPadSVB.axis = .horizontal
////            keyPadSVB.spacing = 0.0
////            keyPadSVB.alignment = .center
////            keyPadSVB.distribution = .equalSpacing
////            keyPadSVB.backgroundColor = UIColor.red
////            for k4s in 0...14 {
////                let button   = UIButton(type: UIButton.ButtonType.custom) as UIButton
////                button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
////                button.backgroundColor = UIColor.orange
////                button.setTitle( String(k4s), for: UIControl.State.normal)
////                button.tag =  keyCount
//////                let blah = "x" + String(keyCount)
////                let blahIMAGE = UIImage(named: "appIcon")
////                button.setImage(blahIMAGE, for: UIControl.State.normal)
////                keyPadSVB.addArrangedSubview(button)
////                keyCount = keyCount + 1
////            }
////            keyPadSV.addArrangedSubview(keyPadSVB)
////        }
////        keyPadWindow.addSubview(keyPadSV)
//        self.view.addSubview(keyPadSV)
        var subViews: [UIView] = []
        for _ in 0...5 {
            let myView = UIView()
            var newFrame = myView.frame

            newFrame.size.width = 200
            newFrame.size.height = 200
            myView.frame = newFrame
//            myView.frame.size.height = 100
//            myView.heightAnchor.constraint(equalToConstant: CGFloat(10.0 * Float(i + 1)))
            myView.backgroundColor = .orange
            subViews.append(myView)
            self.verticalStackView.addArrangedSubview(myView)
        }
        
        
//            let stackView = UIStackView(arrangedSubviews: subViews)
//            stackView.axis = .vertical
//            stackView.spacing = 10
//            stackView.distribution = .fillEqually
//
//            view.addSubview(stackView)
//
//            //        stackView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
//
//            // autolayout constraint
//            stackView.translatesAutoresizingMaskIntoConstraints = false

//        NSLayoutConstraint.activate([stackView.topAnchor.constraint(equalTo: favTableView.topAnchor), stackView.leftAnchor.constraint(equalTo: view.leftAnchor), stackView.rightAnchor.constraint(equalTo: view.rightAnchor), stackView.heightAnchor.constraint(equalToConstant: 2000)])
        
//        let scrollView = UIScrollView()
//        scrollView.backgroundColor = UIColor.blue
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(scrollView)
//
//        let margins = view.layoutMarginsGuide
//        scrollView.leadingAnchor.constraint(equalTo: margins.leadingAnchor)
//        scrollView.topAnchor.constraint(equalTo: margins.topAnchor)
//        NSLayoutConstraint(item: scrollView, attribute: NSLayoutConstraint)
        
    }
}
