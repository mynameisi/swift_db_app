//
//  ViewController.swift
//  DBApp
//
//  Created by wgz on 2016/12/3.
//  Copyright © 2016年 wgzzzdxwgz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var databasePath:String = ""    //这个全局变量用来存储：数据库文件的位置

    override func viewDidLoad() {
        super.viewDidLoad()
        /* 找到APP的所在的系统目录，获得目录下的数据库文件 "contacts.db" */
        let filemgr = NSFileManager.defaultManager()
        let dirPaths = filemgr.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        databasePath = dirPaths[0].URLByAppendingPathComponent("contacts.db", isDirectory: false).path!
        
        /* 以下代码功能: */
        /* 如果数据库文件不存在 */
        /* 利用 FMDB 根据 SQL 创建一个数据库 */
        if !filemgr.fileExistsAtPath(databasePath) {
            let contactDB = FMDatabase(path: databasePath)
            
            if contactDB == nil {
                print("Error: \(contactDB?.lastErrorMessage())")
            }
            
            if (contactDB?.open())! {
                /* 此处是创建数据库的SQL语句 */
                let sql_stmt = "CREATE TABLE IF NOT EXISTS CONTACTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, ADDRESS TEXT, PHONE TEXT)"
                if !(contactDB?.executeStatements(sql_stmt))! {
                    print("Error: \(contactDB?.lastErrorMessage())")
                }
                contactDB?.close() //创建完成后关闭数据库
            } else {
                print("Error: \(contactDB?.lastErrorMessage())")
            }
        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //-------所有的界面元素链接------//
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var status: UILabel!
    
    //-------当用户点击保存的时候---------//
    @IBAction func saveData(sender: AnyObject) {
        let contactDB = FMDatabase(path: databasePath)//链接数据库
        
        if (contactDB?.open())! {  //打开数据库
            
            /* 插入数据的 SQL 语句 */
            let insertSQL = "INSERT INTO CONTACTS (name, address, phone) VALUES ('\(name.text!)', '\(address.text!)', '\(phone.text!)')"
        
            /* 获得 SQL 语句的执行结果 */
            let result = contactDB?.executeUpdate(insertSQL, withArgumentsInArray: nil)
            
            
            if !result! { //如果失败，显示添加失败
                status.text = "Failed to add contact"
                print("Error: \(contactDB?.lastErrorMessage())")
            } else { // 如果结果成功，就显示已经添加输入，并清楚输入内容
                status.text = "Contact Added"
                name.text = ""
                address.text = ""
                phone.text = ""
            }
        } else {    //如果没有成功打开数据库，显示错误
            print("Error: \(contactDB?.lastErrorMessage())")
        }
    }
    
    //---------当用户点击查询的时候-------------//
    @IBAction func findContact(sender: AnyObject) {
        let contactDB = FMDatabase(path: databasePath as String)
        
        if (contactDB?.open())! {
            /* SQL 查询语句 */
            let querySQL = "SELECT address, phone FROM CONTACTS WHERE name = '\(name.text!)'"
            
            /* 把查询结果存入set: results */
            let results:FMResultSet? = contactDB?.executeQuery(querySQL, withArgumentsInArray: nil)
            
            /* 通过next方法获得set的第一个元素，也就是从数据库中查到的第一个元素 */
            if results?.next() == true {    //如果有，表示有结果，就把结果显示在输入框中
                address.text = results?.stringForColumn("address")
                phone.text = results?.stringForColumn("phone")
                status.text = "找到数据"
            } else {    //如果没有，就表示没有结果，就显示：没有找到
                status.text = "没找到数据"
                address.text = ""
                phone.text = ""
            }
            contactDB?.close()  //关闭数据库
        } else {
            //如果没有成功打开数据库，显示错误
            print("Error: \(contactDB?.lastErrorMessage())")
        }
    }
    
    

    

    
    
}

