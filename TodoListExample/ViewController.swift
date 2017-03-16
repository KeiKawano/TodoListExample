//
//  ViewController.swift
//  TodoListExample
//
//  Created by Kei on 2017/03/15.
//  Copyright © 2017年 Kei. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var todoList = [MyTodo]()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 保存しているTodoの読込み処理
        let userDefaults = UserDefaults.standard
        if let storedTodoList = userDefaults.object(forKey: "todoList") as? Data {
            if let unarchiveTodoList = NSKeyedUnarchiver.unarchiveObject(with: storedTodoList) as? [MyTodo] {
                todoList.append(contentsOf: unarchiveTodoList)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tapAddButton(_ sender: Any) {
        // アラートダイアログを生成
        let alertController = UIAlertController(title: "TODO追加", message: "TODOを入力してください", preferredStyle: UIAlertControllerStyle.alert)
        // テキストエリアを追加
        alertController.addTextField(configurationHandler: nil)
        // OKボタンを追加
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default){(action:UIAlertAction) in
            //ボタンがタップされたときの処理
            if let textField = alertController.textFields?.first {
                //ToDoの配列に入力値を挿入（先頭に挿入する）
                let myTodo = MyTodo()
                myTodo.todoTitle = textField.text!
                self.todoList.insert(myTodo, at: 0)
                // テーブルに行が追加されたことをテーブルに通知
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.right)
                // Todoの保存処理
                let userDefaults = UserDefaults.standard
                // Data型にシリアライズする
                let data = NSKeyedArchiver.archivedData(withRootObject: self.todoList)
                userDefaults.set(data, forKey: "todoList")
                userDefaults.synchronize()
            }
        }
        // OKボタンを追加
        alertController.addAction(okAction)
        
        // CANCELボタンがタップされたときの処理
        let cancelButton = UIAlertAction(title: "CANCEL", style: UIAlertActionStyle.cancel, handler: nil)
        // CANCELボタンを追加
        alertController.addAction(cancelButton)
        
        // アラートダイアログを表示
        present(alertController, animated: true, completion: nil)
    }
    
    // テーブルの行数を返却する
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Todoの配列の長さを返却する
        return todoList.count
    }
    
    // テーブルの行ごとのセルを返却する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Storyboadで設定したトドCell識別子を利用して再利用可能なセルを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
        // 行番号にあったToDoの情報を取得
        let myTodo = todoList[indexPath.row]
        // セルのラベルにToDoのタイトルをセット
        cell.textLabel?.text = myTodo.todoTitle
        // セルのチェックマーク状態をセット
        if myTodo.todoDone {
            //チェックあり
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            // チェックなし
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        return cell
    }
    // セルをタップしたときの処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let myTodo = todoList[indexPath.row]
        //完了済み⇔未完了
        myTodo.todoDone = !myTodo.todoDone
        // セルの状態を変更
        tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        // データ保存。Data型にシリアライズする
        let data: Data = NSKeyedArchiver.archivedData(withRootObject: todoList)
        // UserDefaultsに保存
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: "todoList")
        userDefaults.synchronize()
    }

    // 独自クラスをシリアライズする際には、NSObjectを継承しNSCodingプロトコルに準拠する必要がある
    class MyTodo: NSObject, NSCoding {
        // Todoのタイトル
        var todoTitle: String?
        // Todoを完了したかどうかを表すグラフ
        var todoDone: Bool = false
        // コンストラクタ
        override init() {
        
        }
        // NSCodingプロトコルに宣言されているデシリアライズ処理。デコード処理とも呼ばれる
        required init?(coder aDecoder: NSCoder) {
            todoTitle = aDecoder.decodeObject(forKey: "todoTitle") as? String
            todoDone = aDecoder.decodeBool(forKey: "todoDone")
        }
        // NSCodingプロトコルに宣言されているシリアライズ処理。エンコード処理とも呼ばれる
        func encode(with aCoder: NSCoder) {
            aCoder.encode(todoTitle, forKey: "todoTitle")
            aCoder.encode(todoDone, forKey: "todoDone")
        }
    }
}

