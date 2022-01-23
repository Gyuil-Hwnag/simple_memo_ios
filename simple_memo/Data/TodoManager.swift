//
//  TodoManager.swift
//  simple_memo
//
//  Created by 황규일 on 2022/01/23.
//

import Foundation
import CoreData

// Singleton 싱글톤
class TodoManager {
    static let mytodo = TodoManager()
    private init () {
        
    }
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var todoList = [Todo]()
    
    // filter 처리된것
    var filteredArr: [Todo] = []
    
    func addTodo(_ select_day: String?, todo: String?) {
        let newTodo = Todo(context: mainContext)
        newTodo.todo = todo
        newTodo.date = select_day
        
        todoList.insert(newTodo, at: todoList.count)
        saveContext()
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "simple_memo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
