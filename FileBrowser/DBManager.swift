//
//  DBManager.swift
//  FileBrowser
//
//  Created by yongjie_zou on 2018/5/21.
//

import UIKit
import SQLite3

class DBManager: NSObject {
    let file:FBFile
    var db:OpaquePointer?
    var tables:Array<String>?
    var tableData: [String:[[DBUnitData]]] = [:]

    init(file:FBFile) {
        self.file = file
        super.init()
        self.db = openDatabase(filename: file.filePath.absoluteString)
        self.tables = queryAllTableNames()
        queryAllData()
    }
    
    func openDatabase(filename:String) -> OpaquePointer? {
        var db: OpaquePointer? = nil
        if sqlite3_open(filename, &db) == SQLITE_OK {
            print("Successfully opened connection to database at \(filename)")
            return db
        } else {
            print("Unable to open database. Verify that you created the directory described " +
                "in the Getting Started section.")
//            PlaygroundPage.current.finishExecution()
            return nil
        }
    }
    
    func queryAllData() {
        for tableName in self.tables! {
            tableData.updateValue(queryTable(table: tableName)!, forKey: tableName)
        }
    }
    
    func queryAllTableNames() -> [String] {
        let queryStatementString = "select name from sqlite_master where type='table' order by name"
        var queryStatement: OpaquePointer? = nil
        var arr = [String]()
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let columns = sqlite3_column_count(queryStatement)
                for i in 0..<columns {
                    let chars = UnsafePointer<CUnsignedChar>(sqlite3_column_text(queryStatement, i))
                    let value = String.init(cString: chars!)
                    arr.append(value)
                }
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        return arr
    }
    
    func queryTable(table:String) -> [[DBUnitData]]? {
        let queryStatementString = "select * from " + table
        var queryStatement: OpaquePointer? = nil
        var arr:[[DBUnitData]] = []
        // 1
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let columns = sqlite3_column_count(queryStatement)
                var row:[DBUnitData] = Array()
                for i in 0..<columns {
                    let type = sqlite3_column_type(queryStatement, i)
                    let chars = UnsafePointer<CChar>(sqlite3_column_name(queryStatement, i))
                    let name =  String.init(cString: chars!, encoding: String.Encoding.utf8)
                    let unit = DBUnitData.init()
                    unit.key = name

                    var value: Any
                    switch type {
                    case SQLITE_INTEGER:
                        value = sqlite3_column_int(queryStatement, i)
                        unit.type = DBUnitType.int
                    case SQLITE_FLOAT:
                        value = sqlite3_column_double(queryStatement, i)
                        unit.type = DBUnitType.float
                    case SQLITE_TEXT:
                        let chars = UnsafePointer<CUnsignedChar>(sqlite3_column_text(queryStatement, i))
                        value = String.init(cString: chars!)
                        unit.type = DBUnitType.string
                    case SQLITE_BLOB:
                        let data = sqlite3_column_blob(queryStatement, i)
                        let size = sqlite3_column_bytes(queryStatement, i)
                        value = NSData(bytes:data, length:Int(size))
                        unit.type = DBUnitType.bool
                    default:
                        value = ""
                        unit.type = DBUnitType.unknown
                        ()
                    }
                    
                    unit.value = value
                    row.append(unit)
                }
                arr.append(row)
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        // 6
        sqlite3_finalize(queryStatement)
        
        return arr
    }
}

class DBUnitData: NSObject {
    var key: String?
    var value: Any? {
        didSet {
            self.varlueString = "\(value ?? "")"
        }
    }
    var type: DBUnitType?
    var varlueString:String?
    
    override init() {
        key = nil
        value = nil
        type = DBUnitType.unknown
    }
}

enum DBUnitType {
    case string
    case int
    case float
    case bool
    case unknown
}
