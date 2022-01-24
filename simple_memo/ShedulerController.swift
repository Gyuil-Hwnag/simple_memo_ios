//
//  ShedulerController.swift
//  simple_memo
//
//  Created by 황규일 on 2022/01/23.
//

import Foundation
import UIKit
import FSCalendar

class SchdulerController: UIViewController {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var newTodoText: UITextField!
    
    var token: NSObjectProtocol?
    
    var filteredTodo = [Todo]()
    var events = [String]()
    
    var isFiltering: Bool = false
    
    // observal 낭비 소멸자
    deinit{
        if let token = token {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true) {
          self.present(MemoListTableViewController(), animated: true, completion: nil)
        }
    }
    @IBOutlet weak var collectionView: UICollectionView!
    
    var select_day: String = ""
    var event_day: String = ""
    // add click event
    @IBAction func onClick(_ sender: Any) {
        if(newTodoText.text != "" && select_day != ""){
            TodoManager.mytodo.addTodo(select_day, todo: newTodoText.text)
            print(select_day)
            print(newTodoText.text!)
            collectionView.reloadData()
            updateSearchResults(selected_day: select_day)
//            events.insert(event_day, at: events.count)
        }
        else{
            let alert = UIAlertController(title: "알림", message: "날짜또는 내용을 입력해주세요", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "확인", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        }
    }

    // Date Formatter
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set delegate & datasource
        calendar.delegate = self
        calendar.dataSource = self
        
        calendar.backgroundColor = UIColor(red: 241/255, green: 249/255, blue: 255/255, alpha: 1)
        calendar.appearance.selectionColor = UIColor(red: 38/255, green: 153/255, blue: 251/255, alpha: 1)
        calendar.appearance.todayColor = UIColor(red: 188/255, green: 224/255, blue: 253/255, alpha: 1)
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        
        // 다중선택
//        calendar.allowsMultipleSelection = true
//        calendar.swipeToChooseGesture.isEnabled = true
        // 스와이프 스크롤 작동 여부 ( 활성화하면 좌측 우측 상단에 다음달 살짝 보임, 비활성화하면 사라짐 )
        calendar.scrollEnabled = true
        // 스와이프 스크롤 방향 ( 버티칼로 스와이프 설정하면 좌측 우측 상단 다음달 표시 없어짐, 호리젠탈은 보임 )
//        calendar.scrollDirection = .vertical
        // 선택된 날짜의 모서리 설정 ( 0으로 하면 사각형으로 표시 )
//        calendar.appearance.borderRadius = 0
        dateFormatter.dateFormat = "yyyy-MM-dd"
        view.addSubview(calendar)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "CSCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "CSCollectionViewCell")
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Data Base Meory 연동
        TodoManager.mytodo.fetchTodo()
        collectionView.reloadData()
        
        // observal 구현 안했을때 사용
//        tableView.reloadData()
//        print(#function)
    }
    
}


extension SchdulerController : FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    // 날짜 선택 시 콜백 메소드
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        select_day = dateFormatter.string(from: date)
        print(dateFormatter.string(from: date) + " 선택됨")
        
        updateSearchResults(selected_day: select_day)
    }
    // 날짜 선택 해제 시 콜백 메소드
    public func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        select_day = ""
        print(dateFormatter.string(from: date) + " 해제됨")
    }
    
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
//        if self.events.contains(dateFormatter.string(from: date)) {
//            return "일정있음"
//        }
//        else {
//            return nil
//        }
                
            switch dateFormatter.string(from: date) {
            case dateFormatter.string(from: Date()):
                return "오늘"
            case "2022-01-20":
                return "출근"
            case "2022-01-21":
                return "지각"
            case "2022-01-22":
                return "결근"
            default:
                return nil
            }
    }
    
    func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
        switch dateFormatter.string(from: date) {
        case "2022-01-27":
            return "D-day"
        default:
            return nil
        }
    }
    
//    //이벤트 표시 개수
//    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
//        if self.events.contains(dateFormatter.string(from: date)) {
//            return 1
//        } else {
//            return 0
//        }
//    }
}

// cell data
extension SchdulerController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.isFiltering {
            return filteredTodo.count
          }
            
        return TodoManager.mytodo.todoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CSCollectionViewCell", for: indexPath) as? CSCollectionViewCell else{
            return UICollectionViewCell()
        }
        
        let target: Todo
        if self.isFiltering {
            target = self.filteredTodo[indexPath.row]
        }
        else{
            target = TodoManager.mytodo.todoList[indexPath.row]
        }
//        let target: Todo = TodoManager.mytodo.todoList[indexPath.row]
        cell.todo.text = target.todo
        cell.date.text = target.date
        setViewShadow(backView: cell)
        return cell
        
//        // ✅ sizeToFit() : 텍스트에 맞게 사이즈가 조절
//        cell.todo?.sizeToFit()
//        // ✅ cellWidth = 글자수에 맞는 UILabel 의 width + 20(여백)
//        let cellWidth = cell.todo.frame.width + 20
//        cell.todo.shadowOffset = CGSize(width: cellWidth, height: 10)
        
    }
    
}

extension SchdulerController {
    func setViewShadow(backView: UIView) {
        backView.layer.masksToBounds = true
        backView.layer.cornerRadius = 10
        backView.layer.borderWidth = 1
        
        
        backView.layer.backgroundColor = CGColor(red: 241/255, green: 249/255, blue: 255/255, alpha: 1)

        backView.layer.masksToBounds = false
        backView.layer.shadowOpacity = 0.8
        backView.layer.shadowOffset = CGSize(width: -2, height: 2)
        backView.layer.shadowRadius = 3
    }
    
//    private func setupFlowLayout() {
//        let flowLayout = UICollectionViewFlowLayout()
//        flowLayout.sectionInset = UIEdgeInsets.zero
//        flowLayout.minimumInteritemSpacing = 10
//        flowLayout.minimumLineSpacing = 10
//
//        let halfWidth = UIScreen.main.bounds.width / 1
//        flowLayout.itemSize = CGSize(width: halfWidth * 0.9 , height: halfWidth * 0.9)
//        self.collectionView.collectionViewLayout = flowLayout
//    }
}

extension SchdulerController {
    func updateSearchResults(selected_day: String) {
        let text: String = selected_day
        self.filteredTodo = TodoManager.mytodo.todoList.filter {
            $0.date!.localizedCaseInsensitiveContains(text)
        }
        self.collectionView.reloadData()
        isFiltering = true
//        dump(self.filteredMemo)
    }
}
