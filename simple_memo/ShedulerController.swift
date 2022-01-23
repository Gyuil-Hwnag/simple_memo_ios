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
    
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true) {
          self.present(MemoListTableViewController(), animated: true, completion: nil)
        }
    }
    @IBOutlet weak var collectionView: UICollectionView!
    
    var select_day: String = ""
    // add click event
    @IBAction func onClick(_ sender: Any) {
        if(newTodoText.text != "" && select_day != ""){
            TodoManager.mytodo.addTodo(select_day, todo: newTodoText.text)
            print(select_day)
            print(newTodoText.text!)
            collectionView.reloadData()
            
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
        // 다중선택
        calendar.allowsMultipleSelection = true
        calendar.swipeToChooseGesture.isEnabled = true
        // 스와이프 스크롤 작동 여부 ( 활성화하면 좌측 우측 상단에 다음달 살짝 보임, 비활성화하면 사라짐 )
        calendar.scrollEnabled = true
        // 스와이프 스크롤 방향 ( 버티칼로 스와이프 설정하면 좌측 우측 상단 다음달 표시 없어짐, 호리젠탈은 보임 )
//        calendar.scrollDirection = .vertical
        // 선택된 날짜의 모서리 설정 ( 0으로 하면 사각형으로 표시 )
//        calendar.appearance.borderRadius = 0
        dateFormatter.dateFormat = "yyyy-MM-dd"
        view.addSubview(calendar)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
}


extension SchdulerController : FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    // 날짜 선택 시 콜백 메소드
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        select_day = dateFormatter.string(from: date)
        print(dateFormatter.string(from: date) + " 선택됨")
    }
    // 날짜 선택 해제 시 콜백 메소드
    public func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        select_day = ""
        print(dateFormatter.string(from: date) + " 해제됨")
    }
    
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
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
}

// cell data
extension SchdulerController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TodoManager.mytodo.todoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CSCollectionViewCell
        
        let target: Todo = TodoManager.mytodo.todoList[indexPath.row]
        cell.todo?.text = target.todo
        cell.backgroundColor = .lightGray
        cell.todo.backgroundColor = .yellow
        
        return cell
    }
}
