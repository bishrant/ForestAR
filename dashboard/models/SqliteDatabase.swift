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
    
    func getDetailsUsingImageName(imageName: String) -> ARImageEntry {
        let config: AppConfigJSON = Service.sharedInstance.getAppConfig()
        let imgSplit = imageName.components(separatedBy: "___")
        var imgData: ARImageEntry!
        for img in config.images {
            if (img.folderName == imgSplit[0] && img.imageName == imgSplit[1]) {
                imgData = img
                break
            }
        }
        return imgData
    }
    
    func createFavTableIfNotExists() {
        if sqlite3_exec(self.db, "CREATE TABLE IF NOT EXISTS Favourites (idpk INTEGER PRIMARY KEY AUTOINCREMENT, id INTEGER, title TEXT, imageName TEXT, url TEXT, videoLink TEXT, folderName TEXT, sharingText TEXT, description TEXT)", nil, nil, nil) != SQLITE_OK {
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
    
    func insertIntoFavTable(id: Int, title: String, imageName: String, url: String, videoLink: String, folderName: String, sharingText: String, description: String) {
        var suc: Bool = false
          do {
              var db = self.getDb()
              let stmt = try db!.prepare("INSERT INTO Favourites (id, title, imageName, url, videoLink, folderName, sharingText, description) VALUES (?, ?, ?, ?, ?, ?, ?, ?)")
              try stmt.run([id, title, imageName, url, videoLink, folderName, sharingText, description])
              suc = true
              db = nil
          } catch {
              print ("error in new lib")
          }
          print("result of insert", suc)
    }
    
    func toggleFavEntry(id: Int, title: String, imageName: String, url: String, videoLink: String, folderName: String, sharingText: String, description: String) -> Bool {
        var _success: Bool = false;
        if(getFavouritesCount(imageName: imageName, folderName: folderName) < 1) {
            self.insertIntoFavTable(id: id, title: title, imageName: imageName, url: url, videoLink: videoLink, folderName: folderName, sharingText: sharingText, description: description)
                _success = true
            } else {
            _success = self.deleteFavEntryByPhotoName(id: id, imageName: imageName, folderName: folderName)
            }
        return _success
    }
    
    func deleteFavEntryByPhotoName(id: Int, imageName: String, folderName: String) -> Bool {
      var suc: Bool = false
        do {
            var db = self.getDb()
            let stmt = try db!.prepare("delete from Favourites where id =? and photo = ? and folderName = ?")
            try stmt.run([id, imageName, folderName])
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
    
    func getFavouritesCount(imageName: String, folderName: String)  -> Int64 {
        var rowcount: Int64 = 0
        do {
            var db = self.getDb()
            let stmt = try db!.prepare("select count(*) from Favourites where imageName = ? and folderName = ?")
            rowcount = try stmt.scalar([imageName, folderName]) as! Int64
            db = nil
        } catch {
            print ("error in new lib")
        }
        return rowcount;
    }
    
    func deleteFavEntry(idpk: Int32) -> Bool {
        var suc: Bool = false
        do {
            var db = self.getDb()
            let stmt = try db!.prepare("delete from Favourites where idpk = ?")
            try stmt.run(idpk as? Binding)
            suc = true
            db = nil
        } catch {
            print ("error in new lib")
        }
        return suc;
    }
    
    func getFavourites()  -> [FavouritesStruct] {
        let idpk = Expression<Int?>("idpk")
        let id = Expression<Int?>("id")
        let title = Expression<String?>("title")
        let url = Expression<String?>("url")
        let imageName = Expression<String?>("imageName")
        let videoLink = Expression<String?>("videoLink")
        let folderName = Expression<String?>("folderName")
        let sharingText = Expression<String?>("sharingText")
        let description = Expression<String?>("description")
        var favouritesListPrivate = [FavouritesStruct] ()
        do {
            var db = self.getDb()
            let Favs = Table("Favourites").order(title.asc)
            try autoreleasepool{
                for f in (try db?.prepare(Favs))! {
                    favouritesListPrivate.append(
                        FavouritesStruct(
                            idpk: try f.get(idpk)!,
                            id: try f.get(id)!,
                            title: try f.get(title)!,
                            url: try f.get(url)!,
                            imageName: try f.get(imageName)!,
                            videoLink: try f.get(videoLink)!,
                            folderName: try f.get(folderName)!,
                            sharingText: try f.get(sharingText)!,
                            description: try f.get(description)!
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
