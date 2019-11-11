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
    
    func initializeDB() -> Void {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("TreeID.sqlite")
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database");
        } else {
            print("database opened");
            self.db = db!
            createFavTable()
        }
    }
    
    func createFavTable() -> Void {
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Favourites (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, link TEXT, photo TEXT, video TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(self.db)!)
            print("error creating table: \(errmsg)")
        } else {
            print("table created");
        }
    }
    
    func openDB() -> Bool {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("TreeID.sqlite")

        if sqlite3_open(fileURL.path, &self.db) != SQLITE_OK {
            print("error opening database");
            return false;
        } else {
            return true;
        }
    }
    
    func insertIntoFavTable(nameP: String, linkP: String, photoP: String, videoP: String) {
        var stmt: OpaquePointer?
        let queryString = "INSERT INTO Favourites (name, link, photo, video) VALUES (?, ?, ?, ?)"
        if sqlite3_prepare(self.db, queryString, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(self.db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        // binding the parameters
        sqlite3_bind_text(stmt, 1, NSString(string: nameP).utf8String, -1, nil);
        sqlite3_bind_text(stmt, 2, NSString(string: linkP).utf8String, -1, nil);
        sqlite3_bind_text(stmt, 3, NSString(string: photoP).utf8String, -1, nil);
        sqlite3_bind_text(stmt, 4, NSString(string: videoP).utf8String, -1, nil);
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            print("failed to insert");
        } else {
            print ("saved to db");
        }
    }
    
    func toggleFavEntry(n: String, l: String, p: String, v: String) {
        if (self.openDB()) {
            if(getFavouritesCount(photoName: p) < 1) {
                self.insertIntoFavTable(nameP: n, linkP: l, photoP: p, videoP: v)
            } else {
                self.deleteFavEntryByPhotoName(photoName: p)
            }
        }
       
    }
    
    func deleteFavEntryByPhotoName(photoName: String) -> Bool {
        let deleteQuery = "Delete FROM Favourites where photo = ?"
        var stmt: OpaquePointer?
        if sqlite3_prepare(db, deleteQuery, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, photoName, -1, nil)
            if (sqlite3_step(stmt) == SQLITE_DONE) {
                print("deleted " + photoName);
                return true;
                
            } else {
                print("error deleting favourites");
                return false
            }
        } else {
        return false;
        }
    }
    
    func getFavouritesCount(photoName: String)  -> Int {
        self.openDB()
        var rowcount: Int = 0
        let queryString = "SELECT count() FROM Favourites where photo = ?"
        var stmt:OpaquePointer?
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK{
            sqlite3_bind_text(stmt, 1, photoName, -1, nil)
            while(sqlite3_step(stmt) == SQLITE_ROW){
                rowcount = Int(sqlite3_column_int(stmt, 0));
            }
        }
        return rowcount;
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
            let photo = String(cString: sqlite3_column_text(stmt, 3))
            let video = String(cString: sqlite3_column_text(stmt, 4))
            favouritesListPrivate.append(
                FavouritesStruct(
                    id: Int(id),
                    name: String(describing: name),
                    link: String(describing: link),
                    photo: String(describing: photo),
                    video: String(describing: video)
            
            ))
            
            print(id, name, link, photo, video)
        }
        return favouritesListPrivate;
    }
    
}
