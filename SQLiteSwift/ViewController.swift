//
//  ViewController.swift
//  SQLiteSwift
//
//  Created by Surya Kameswara Rao Ravi on 14/11/16.
//  Copyright © 2016 siricomm5. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //Database
    var dbName              : String    = "database.sqlite"
    
    //Database Queries
    var strcreateTable      : String    = "CREATE TABLE IF NOT EXISTS News(Id INT PRIMARY KEY NOT NULL, Title TEXT, Description TEXT, ImageURL TEXT, Language TEXT, Category TEXT);"
    var strInsertStatement  : String    = "INSERT INTO News (Id, Title, Description) VALUES(1,\"test title\",\"test description\");"
    var strInsertStatement1  : String    = "INSERT INTO Newsxxx (Id, Title, Description) VALUES(1,\"test title\",\"test description\");"
    var strQueryStatement   : String    = "SELECT * FROM News ORDER BY id DESC LIMIT 30;"
    var strSpecificQuery    : String    = "SELECT * FROM News WHERE Id = "
    var strCountQuery       : String    = "SELECT COUNT(*) FROM NEWS;"
    var strDeleteStatement  : String    = "DELETE FROM News WHERE Id = 1 ;"
    var strUpdateStatement  : String    = "UPDATE News SET Title = \"updated title\", Description = \"updated description\" WHERE Id = 1;"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.initDatabase()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Functions for database operations
    func initDatabase(){
        
        //database operations
        let dbObj = SQLiteSwift()
        if dbObj.openDatabase(strDBName: self.dbName){
            if dbObj.doesSqliteDBExist(strDBName: self.dbName){
                if dbObj.executeQuery(strQuery: strcreateTable){
                    let _ = dbObj.executeQuery(strQuery: self.strInsertStatement)
                }
            }
            //Verify Insert
            var resultSet = dbObj.executeSelect(selectQuery: self.strQueryStatement)
            print(resultSet)
            print(dbObj.executeCount(countQuery: strCountQuery))
            //Now update
            let _ = dbObj.executeQuery(strQuery: strUpdateStatement)
            resultSet = dbObj.executeSelect(selectQuery: self.strQueryStatement)//verify
            print(resultSet)
            print(dbObj.executeCount(countQuery: strCountQuery))
            //Then Delete
            let _ = dbObj.executeQuery(strQuery: strDeleteStatement)
            resultSet = dbObj.executeSelect(selectQuery: self.strQueryStatement)//verify
            print(resultSet)
            print(dbObj.executeCount(countQuery: strCountQuery))
        }
        dbObj.closeDatabase()
        
    }//end func initDatabase()
    
}

