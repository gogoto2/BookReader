//
//  BooksTableViewController.swift
//  BookReader
//
//  Created by 李刚 on 2018/5/25.
//  Copyright © 2018年 李刚. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import Kingfisher
import SwiftSoup

class BooksTableViewController: UITableViewController,UISearchBarDelegate,UISearchControllerDelegate {
    var books = [Book]()
    let sc = UISearchController(searchResultsController: nil)
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var BookCellContentCache = [Int:BookCellContent]()
    var isSearching = false
    let mainPageGetter = GetMainPage()
    
    func addOne() {
        let nb = Book(context: appDelegate.persistentContainer.viewContext)
        nb.path = "https://m.biqudu.com/16_16431/"
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    func loadAll(){
        let fetch:NSFetchRequest<Book> = Book.fetchRequest()
        if let fetchResult =  try? appDelegate.persistentContainer.viewContext.fetch(fetch) {
            books = fetchResult
            tableView.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainPageGetter.updateMainPageDelegate = self
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        navigationController?.navigationBar.barStyle = .blackTranslucent
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        navigationController?.navigationBar.tintColor = .white
        tableView.register(UINib(nibName: "BookTableViewCell", bundle: nil), forCellReuseIdentifier: "book_cell")
        //滑动时隐藏searchBar
        navigationItem.hidesSearchBarWhenScrolling = true
        //将searchController赋值给navigationItem
        navigationItem.searchController = sc
        sc.searchBar.placeholder = "书名"
        sc.searchBar.showsCancelButton = false
        sc.searchBar.delegate = self
        sc.searchBar.setValue("取消", forKey: "_cancelButtonText")
        sc.delegate = self
        loadAll()
    }
    @IBAction func refreshBooks(_ sender: UIRefreshControl) {
        loadAll()
        refreshControl?.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        let counter = books.count > 0 ? 1 : 0
        if counter == 0 {
            tableView.separatorStyle = .none
            let bg = UILabel()
            let paraph = NSMutableParagraphStyle()
            paraph.lineSpacing = 8
            bg.attributedText = NSAttributedString(string: "\n\n\nNothing to Read", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 20),NSAttributedStringKey.paragraphStyle:paraph,NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)])
            bg.numberOfLines = 0
            bg.textAlignment = .center
            tableView.backgroundView = bg
        }else {
            tableView.separatorStyle = .singleLine
            tableView.backgroundView = nil
        }
        
        return counter
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return books.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "book_cell", for: indexPath) as! BookTableViewCell
        cell.bookName.text = "";
        cell.updateTime.text = "";
        cell.latestedChapter.setTitle("", for: .normal)
        cell.latestedChapter.isUserInteractionEnabled = false
        cell.origin.text = ""
        cell.isUserInteractionEnabled = false
        let index = indexPath.row
        //chech weather has local cache
        if let cellCache = BookCellContentCache[index] {
            cell.bookName.text = cellCache.name + "\t" + cellCache.author
            cell.updateTime.text = cellCache.time
            cell.latestedChapter.setTitle(cellCache.chapter, for: .normal)
            cell.bookCover.kf.setImage(with: URL(string: cellCache.img))
            cell.latestedChapter.isUserInteractionEnabled = true
            cell.isUserInteractionEnabled = true
            cell.origin.text = cellCache.host
        }else{
            mainPageGetter.getMainPage(path: books[index].path!, index: index)
        }
        //cell.showLatestedChapterDelegate = self
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
extension BooksTableViewController: UpdateMainPageDelegate {
    func updateMainPage(index: Int, content: BookCellContent) {
        BookCellContentCache[index] = content
        tableView.reloadRows(at: [IndexPath.init(row: index, section: 0)], with: .fade)
    }
}
