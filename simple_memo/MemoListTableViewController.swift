//
//  MemoListTableViewController.swift
//  simple_memo
//
//  Created by 황규일 on 2022/01/16.
//

import UIKit

class MemoListTableViewController: UITableViewController {

    var date = ""
    // date format
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .short
        f.locale = Locale(identifier: "Ko_kr")  // korean settings
        return f
    }()
    
    var token: NSObjectProtocol?
    
    var filteredMemo = [Memo]()
    
    // observal 낭비 소멸자
    deinit{
        if let token = token {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    // 화면이 준비될 때
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
            if let vc = segue.destination as? DetailViewController {
                vc.memo = DataManager.shared.memoList[indexPath.row]
            }
        }
    }
    
    // edit
    @IBAction func editButton(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            sender.title = "Edit"
            tableView.setEditing(false, animated: true)
        }
        else {
            sender.title = "Done"
            tableView.setEditing(true, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // *** Notification observal
        token = NotificationCenter.default.addObserver(forName: ComposeViewController.newMomoDidInsert, object: nil, queue: OperationQueue.main){
            [weak self] (noti) in self?.tableView.reloadData()
        }
        
        // Drag & Drop 기능을 위한 부분
        self.tableView.dragInteractionEnabled = true
        
        // Search Bar navigation title 에서 존재하기
//        let searchController = UISearchController(searchResultsController: nil)
//        searchController.searchBar.placeholder = "Search Memo"
//        self.navigationItem.searchController = searchController
//        self.navigationItem.hidesSearchBarWhenScrolling = false
        setupSearchController()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // 저장버튼 누를때 리스트 최신화
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Data Base Meory 연동
        DataManager.shared.fetchMemo()
        tableView.reloadData()
        
        // observal 구현 안했을때 사용
//        tableView.reloadData()
//        print(#function)
    }
    
    // search
    func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search Memo"
//        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        self.navigationItem.searchController = searchController
        self.navigationItem.title = "Memo"
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }

    var isFiltering: Bool {
        let searchController = self.navigationItem.searchController
        let isActive = searchController?.isActive ?? false
        let isSearchBarHasText = searchController?.searchBar.text?.isEmpty == false
        return isActive && isSearchBarHasText
    }

    // MARK: - Table view data source
    // cell의 크기를 지정
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.isFiltering {
            return filteredMemo.count
          }
            
          return DataManager.shared.memoList.count
    }

    
    // 가장 중요한 메소드 cell 의 구성요소 연결
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        // Configure the cell...
        // Search 기능 추가
        let target: Memo
        if self.isFiltering {
            target = self.filteredMemo[indexPath.row]
        }
        else{
            target = DataManager.shared.memoList[indexPath.row]
        }
        cell.textLabel?.text = target.content
        cell.detailTextLabel?.text = formatter.string(for: target.insertDate)

        return cell
    }
    
    // Override to support conditional editing of the table view.
    // 편집 기능 활성화
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Override to support editing the table view.
    // 편집 스타일
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let target = DataManager.shared.memoList[indexPath.row]
            DataManager.shared.deleteMemo(target)
            DataManager.shared.memoList.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
        }    
    }
    
    // edit 에서 움직이는 drag and drop
    override func tableView(_ tableView: UITableView, moveRowAt indexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("\(indexPath.row) -> \(destinationIndexPath.row)")
        let moveCell = DataManager.shared.memoList[indexPath.row]
        DataManager.shared.memoList.remove(at: indexPath.row)
        DataManager.shared.memoList.insert(moveCell, at: destinationIndexPath.row)
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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

extension MemoListTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text?.lowercased()
        else { return }
        self.filteredMemo = DataManager.shared.memoList.filter {
            $0.content!.localizedCaseInsensitiveContains(text)
        }
        self.tableView.reloadData()
//        dump(self.filteredMemo)
    }
}

