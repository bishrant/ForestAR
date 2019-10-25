//
//  Database.swift
//  dashboard
//
//  Created by Adhikari, Bishrant on 10/22/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import UIKit
import SQLite3

class SqliteDatabase {
    var db: OpaquePointer?
    
    func openDB() -> Bool {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("TreeID.sqlite")

        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database");
            return false;
        } else {
            return true;
        }
    }
    
    func deleteFavEntry(id: Int32) -> Bool {
        let deleteQuery = "Delete FROM Favourites where id = ?"
        var stmt: OpaquePointer?
        if sqlite3_prepare(db, deleteQuery, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, id)
            if (sqlite3_step(stmt) == SQLITE_DONE) {
                print("deleted " + String(id));
                return true;
                
            } else {
                print("error deleting favourites");
                return false
            }
        } else {
        return false;
        }
    }
    
    func getFavourites()  -> [FavouritesStruct] {
        var favouritesListPrivate = [FavouritesStruct] ()
        let queryString = "SELECT * FROM Favourites"
        var stmt:OpaquePointer?
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return favouritesListPrivate;
        }
        
        //traversing through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let name = String(cString: sqlite3_column_text(stmt, 1))
            let link = String(cString: sqlite3_column_text(stmt, 2))
            
            favouritesListPrivate.append(FavouritesStruct(id: Int(id), name: String(describing: name), link: String(describing: link)))
            
            print(id, name, link)
        }
        return favouritesListPrivate;
    }
    
}
