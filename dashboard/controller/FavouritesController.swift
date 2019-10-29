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
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.favTableView.backgroundColor = UIColor.white
        getAllFavourites();
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
        let cell = FavouriteTableCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40), title: fav.name!, id: fav.id)
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
        let deleteSuccess = SqliteDb.deleteFavEntry(id: Int32(sender.id));
        if deleteSuccess {
            self.favouritesList = SqliteDb.getFavourites();
            self.favTableView.reloadData();
            DispatchQueue.main.async { self.favTableView.reloadData() }
        }
    }
}
