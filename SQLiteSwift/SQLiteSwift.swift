//
//  SQLiteSwift.swift
//  SQLiteSwift
//
//  Created by Surya Kameswara Rao Ravi on 11/11/16.
//  Copyright © 2016 siricomm5. All rights reserved.
//
//  Written for SWIFT-3 - A simple and lucid approach
//  

import Foundation

class SQLiteSwift{
    
    //Database pointer
    var db : OpaquePointer!             = nil
    var strDBPath           : String    = ""
    var dbName              : String    = ""
    
    func openDatabase(strDBName : String) -> Bool {//Function to create or open database in Documents directory
        
        var dbConn: OpaquePointer? = nil
        var dbOpened = false
        let docsDir : URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        self.dbName = strDBName
        let dbPath = "\(docsDir.path)/\(self.dbName)"
        self.strDBPath = dbPath

        if sqlite3_open(dbPath, &dbConn) == SQLITE_OK {
            dbOpened = true
            print("Successfully opened connection to database at \(dbPath)")
        } else {
            dbOpened = false
            print("Failed to open database. Verify for database at \(dbPath)")
        }

        self.db = dbConn!
        return dbOpened
        
    }//end openDatabase()
    
    func closeDatabase(){//Function to close database
        
        if self.db != nil{//database is open
            sqlite3_close(self.db)
        }
        
    }//end closeDatabase()
    
    func doesSqliteDBExist(strDBName : String)->Bool{//Verify if database exists in Documents directory
        
        //recommended method using URL based approach
        let dbPath       :URL       = URL(fileURLWithPath: self.strDBPath)
        var sqliteExists : Bool     = false
        
        do{
            
            sqliteExists = try dbPath.checkResourceIsReachable()
            print("An sqlite database exists at this path :: \(dbPath.path) :: \(sqliteExists)")
        }catch{
            sqliteExists = false
            print("SQLite NOT Found at :: \(strDBPath)")
        }
        
        return sqliteExists
    }//end doesSqliteDBExist()
    
    func ifSqliteDBExists(strDBName : String)->Bool{//Verify if database exists in Documents directory
        
        //alternative approach to verify if database exists
        
        let fileManager     : FileManager  = FileManager.default
        var sqliteExists    : Bool         = false
        
        if fileManager.fileExists(atPath:self.strDBPath){
            sqliteExists = true
            print("An sqlite database exists at this path :: \(strDBPath)")
        }else{
            sqliteExists = false
            print("SQLite NOT Found at :: \(strDBPath)")
        }
        
        return sqliteExists
        
    }//end ifSqliteDBExists()
    
    func executeQuery(strQuery : String)->Bool{//Function to execute CREATE, INSERT, UPDATE, DELETE
        
        //flag for query status
        var hasExecuted = false
        
        //support error message logging
        let errmsg : UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>? = nil
        
        //Execute the sqlite query
        let result = sqlite3_exec(self.db, strQuery, nil, nil, errmsg)
        
        //verify result
        if (result != SQLITE_OK){//Fail
            hasExecuted = false
            let strError = String(cString: sqlite3_errmsg(self.db))
            print("FAILED: \(strQuery), error-code-\(sqlite3_errcode(self.db)), \(strError)\n")
        }else{//Pass
            hasExecuted = true
            print("SUCCESS: \(strQuery)")
        }
        
        return hasExecuted
        
    }//end executeQuery()

    func executeSelect(selectQuery:String)->[[String : Any]]{//Function to execute SELECT
        
        var resultSet           = [[String : Any]]()
        let cSql                = selectQuery.cString(using: String.Encoding.utf8)
        var result:CInt         = 0
        var stmt:OpaquePointer? = nil
        
        result = sqlite3_prepare_v2(self.db, cSql!, -1, &stmt, nil)
        if result != SQLITE_OK{
            let strError = String(cString: sqlite3_errmsg(self.db))
            print("FAILED: \(selectQuery), error-code-\(sqlite3_errcode(self.db)), \(strError)\n")
        }else{
            result = sqlite3_step(stmt)
            resultSet.removeAll()
            while result == SQLITE_ROW {
                var Dictionary = [String : Any]()
                let columnCount = sqlite3_column_count(stmt)
                for i in 0..<columnCount{
                    let columnName = sqlite3_column_name(stmt, i)
                    var key = String(cString:columnName!)
                    if key == "" {
                        key = ""
                    }
                    let columnValue = sqlite3_column_text(stmt, i)
                    var value: String!
                    if columnValue != nil {
                        value = String(cString:columnValue!)
                    }else{
                        value = ""
                    }
                    Dictionary[key] = value
                }
                resultSet.append(Dictionary)
                result = sqlite3_step(stmt)
            }
        }
        
        sqlite3_finalize(stmt)
        
        return resultSet
        
    }//end executeSelect()
    
    
    //Execute any count query
    func executeCount(countQuery : String)->Int{//Function to execute SELECT COUNT

        var countValue  :Int                  = 0
        var resultSet   : [[String : Any]]?   = nil
        let strQuery    : String              = countQuery.lowercased()
        
        if strQuery.range(of: "count(") != nil{
             resultSet = executeSelect(selectQuery: countQuery)
        }
        
        if resultSet != nil{
            if resultSet?.count == 1{
                let record = resultSet?[0]
                if record?.keys.count == 1{
                    let strCount : String  = record!.first?.value as! String
                    countValue = Int(strCount)!
                    print("\(countQuery)\nCount value: \(strCount)")
                }
            }
        }
        
        return countValue
        
    }//end executeCount()
    
}
