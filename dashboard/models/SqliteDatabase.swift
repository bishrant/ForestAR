//
//  Database.swift
//  dashboard
//
//  Created by Adhikari, Bishrant on 10/22/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import UIKit
import SQLite3
import SQLite

class SqliteDatabase {
    private var db: OpaquePointer!
    
    init() { }
    
    func initializeDb() {
        var ob: OpaquePointer?
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("TreeID.sqlite")
        if sqlite3_open(fileURL.path, &ob) != SQLITE_OK {
            print("error opening database");
        } else {
            print("database opened");
        }
        self.db = ob!
        self.createFavTableIfNotExists()
    }
    
    func createFavTableIfNotExists() {
        if sqlite3_exec(self.db, "CREATE TABLE IF NOT EXISTS Favourites (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, link TEXT, photo TEXT, video TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(self.db)!)
            print("error creating table: \(errmsg)")
        } else {
            print("table already exists");
        }
        print("table creation function")
        sqlite3_close(self.db)
    }
    
    func openDB() -> OpaquePointer? {
        var dbs: OpaquePointer?
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("TreeID.sqlite")

        if sqlite3_open(fileURL.path, &dbs) != SQLITE_OK {
            print("error opening database");
        }
        return dbs
    }
    
    func insertIntoFavTable(nameP: String, linkP: String, photoP: String, videoP: String) {
        var suc: Bool = false
          do {
              var db = self.getDb()
              let stmt = try db!.prepare("INSERT INTO Favourites (name, link, photo, video) VALUES (?, ?, ?, ?)")
              try stmt.run([nameP, linkP, photoP, videoP])
              suc = true
              db = nil
          } catch {
              print ("error in new lib")
          }
          print("result of insert", suc)
    }
    
    func toggleFavEntry(n: String, l: String, p: String, v: String) -> Bool {
        var _success: Bool = false;
            if(getFavouritesCount(photoName: p) < 1) {
                self.insertIntoFavTable(nameP: n, linkP: l, photoP: p, videoP: v)
                _success = true
            } else {
                _success = self.deleteFavEntryByPhotoName(photoName: p)
            }
        return _success
    }
    
    func deleteFavEntryByPhotoName(photoName: String) -> Bool {
      var suc: Bool = false
        do {
            var db = self.getDb()
            let stmt = try db!.prepare("delete from Favourites where photo = ?")
            try stmt.run(photoName)
            suc = true
            db = nil
        } catch {
            print ("error in new lib")
        }
        return suc;
    }
    
    func getDb() -> Connection? {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("TreeID.sqlite")
        do {
            return try Connection(fileURL.path)
        } catch {
            return nil
        }
    }
    
    func getFavouritesCount(photoName: String)  -> Int64 {
        var rowcount: Int64 = 0
        do {
            var db = self.getDb()
            let stmt = try db!.prepare("select count(*) from Favourites where photo = ?")
            rowcount = try stmt.scalar(photoName) as! Int64
            db = nil
        } catch {
            print ("error in new lib")
        }
        return rowcount;
    }
    
    func deleteFavEntry(id: Int32) -> Bool {
        var suc: Bool = false
        do {
            var db = self.getDb()
            let stmt = try db!.prepare("delete from Favourites where id = ?")
            try stmt.run(id as? Binding)
            suc = true
            db = nil
        } catch {
            print ("error in new lib")
        }
        return suc;
    }
    
    func getFavourites()  -> [FavouritesStruct] {
        let id = Expression<Int?>("id")
        let name = Expression<String?>("name")
        let link = Expression<String?>("link")
        let photo = Expression<String?>("photo")
        let video = Expression<String?>("video")
        var favouritesListPrivate = [FavouritesStruct] ()
        do {
            var db = self.getDb()
            let Favs = Table("Favourites").order(name.asc)
            try autoreleasepool{
                for f in (try db?.prepare(Favs))! {
                    favouritesListPrivate.append(
                        FavouritesStruct(
                            id: try f.get(id)!,
                            name: try f.get(name)!,
                            link: try f.get(link)!,
                            photo: try f.get(photo)!,
                            video: try f.get(video)!
                    ))
                }
            }

            db = nil
        } catch {
            print ("error in new lib")
        }
        return favouritesListPrivate;
    }
}
