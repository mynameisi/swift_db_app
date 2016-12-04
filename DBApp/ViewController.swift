//
//  ViewController.swift
//  DBApp
//
//  Created by wgz on 2016/12/3.
//  Copyright © 2016年 wgzzzdxwgz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filemgr = NSFileManager.defaultManager()
        let dirPaths = filemgr.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        databasePath = dirPaths[0].URLByAppendingPathComponent("contacts.db", isDirectory: false).path!
        
        if !filemgr.fileExistsAtPath(databasePath) {
            let contactDB = FMDatabase(path: databasePath)
            
            if contactDB == nil {
                print("Error: \(contactDB?.lastErrorMessage())")
            }
            
            if (contactDB?.open())! {
                let sql_stmt = "CREATE TABLE IF NOT EXISTS CONTACTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, ADDRESS TEXT, PHONE TEXT)"
                if !(contactDB?.executeStatements(sql_stmt))! {
                    print("Error: \(contactDB?.lastErrorMessage())")
                }
                contactDB?.close()
            } else {
                print("Error: \(contactDB?.lastErrorMessage())")
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //-------我的代码------//
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var status: UILabel!
    
    @IBAction func saveData(sender: AnyObject) {
        let contactDB = FMDatabase(path: databasePath)
        
        if (contactDB?.open())! {
            
            let insertSQL = "INSERT INTO CONTACTS (name, address, phone) VALUES ('\(name.text!)', '\(address.text!)', '\(phone.text!)')"
            
            let result = contactDB?.executeUpdate(insertSQL, withArgumentsInArray: nil)
            
            if !result! {
                status.text = "Failed to add contact"
                print("Error: \(contactDB?.lastErrorMessage())")
            } else {
                status.text = "Contact Added"
                name.text = ""
                address.text = ""
                phone.text = ""
            }
        } else {
            print("Error: \(contactDB?.lastErrorMessage())")
        }
    }
    
    @IBAction func findContact(sender: AnyObject) {
        let contactDB = FMDatabase(path: databasePath as String)
        
        if (contactDB?.open())! {
            let querySQL = "SELECT address, phone FROM CONTACTS WHERE name = '\(name.text!)'"
            
            let results:FMResultSet? = contactDB?.executeQuery(querySQL, withArgumentsInArray: nil)
            
            if results?.next() == true {
                address.text = results?.stringForColumn("address")
                phone.text = results?.stringForColumn("phone")
                status.text = "Record Found"
            } else {
                status.text = "Record not found"
                address.text = ""
                phone.text = ""
            }
            contactDB?.close()
        } else {
            print("Error: \(contactDB?.lastErrorMessage())")
        }
    }
    
    var databasePath:String = ""

    

    
    
}

