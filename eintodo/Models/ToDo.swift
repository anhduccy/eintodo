//
//  ToDo.swift
//  eintodo
//
//  Created by anh :) on 18.06.22.
//

import Foundation
import RealmSwift

///To-Do-Model for Realm/MongoDB
class ToDo: Object, ObjectKeyIdentifiable{
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var title: String
    @Persisted var notes: String
    @Persisted var completed: Bool = false
    @Persisted var deadline: Date
    @Persisted var notification: Date
    @Persisted var marked: Bool = false
    @Persisted var priority: Priotity = .none
    @Persisted var subToDos: RealmSwift.List<SubToDo>
    @Persisted(originProperty: "todos") var list: LinkingObjects<ToDoList>
    
    enum Priotity: Int, PersistableEnum{
        case none, low, medium, high
        
        var text: String{
            switch self{
            case .none:
                return "Keine"
            case .low:
                return "Niedrig"
            case .medium:
                return "Mittel"
            case .high:
                return "Hoch"
            }
        }
        var systemName: String{
            switch self{
            case .none:
                return "questionmark"
            case .low:
                return "exclamationmark"
            case .medium:
                return "exclamationmark.2"
            case .high:
                return "exclamationmark.3"
            }
        }
    }
    
    //FUNCTIONS
    ///Add a to-do with a to-do-model layer to a to-do list in Realm/MongoDB and set a user notification if at least one date is activated.
    static func add(list: ToDoList, model: ToDoModel){
        try? realmEnv.write{
            let obj = realmEnv.objects(ToDoList.self).filter(NSPredicate(format: "_id == %@", list._id)).first!
            obj.todos.append(model.transferToRealm(todo: ToDo()))
            if model.deadline != Date.isNotActive{
                NotificationCenter.updateToDo(title: model.title, id: "\(model._id)", date: model.deadline)
            }
            if model.notification != Date.isNotActive{
                NotificationCenter.updateToDo(title: model.title, id: "\(model._id)", date: model.notification)
            }
        }
    }
    ///Update a to-do with a to-do-model layer in Realm/MongoDB and change the user notification if at least one date is activated
    static func update(todo: ObservedRealmObject<ToDo>.Wrapper, model: ToDoModel){
        if todo.wrappedValue.list.first!._id == model.list._id{
            todo.title.wrappedValue = model.title
            todo.notes.wrappedValue = model.notes
            todo.deadline.wrappedValue = model.deadline
            todo.notification.wrappedValue = model.notification
            todo.marked.wrappedValue = model.marked
            todo.priority.wrappedValue = model.priority
        } else {
            try! realmEnv.write{
                let store = ToDo(value: todo.wrappedValue)
                realmEnv.delete(realmEnv.objects(ToDo.self).filter("_id == %@", todo.wrappedValue._id))
                let list = realmEnv.objects(ToDoList.self).filter(NSPredicate(format: "_id == %@", model.list._id)).first!
                ObservedRealmObject(wrappedValue: list).projectedValue.todos.append(model.transferToRealm(todo: store))
            }
        }
        if model.deadline != Date.isNotActive{
            NotificationCenter.updateToDo(title: model.title, id: "\(model._id)", date: model.deadline)
        } else {
            NotificationCenter.deleteToDo(id: "\(model._id)")
        }
        if model.notification != Date.isNotActive{
            NotificationCenter.updateToDo(title: model.title, id: "\(model._id)", date: model.notification)
        } else {
            NotificationCenter.deleteToDo(id: "\(model._id)")
        }
    }
    ///Delete a to-do from Realm/MongoDB
    static func delete(todo: ToDo){
        if realmEnv.isInWriteTransaction{
            runDelete(todo: todo)
        } else {
            try! realmEnv.write{
               runDelete(todo: todo)
            }
        }
    }
    static func runDelete(todo: ToDo){
        for subToDo in todo.subToDos{
            SubToDo.delete(subToDo: subToDo)
        }
        NotificationCenter.deleteToDo(id: "\(todo._id)")
        realmEnv.delete(realmEnv.objects(ToDo.self).filter("_id = %@", todo._id))
    }
}

///A model layer between data storage (Realm/MongoDB) and UI for type ToDo
class ToDoModel: ObservableObject{
    init(){
        _id = ObjectId()
        title = ""
        notes = ""
        deadline = Date(timeIntervalSince1970: 0)
        notification = Date(timeIntervalSince1970: 0)
        priority = .none
        marked = false
        let lists = ObservedResults(ToDoList.self)
        list = lists.wrappedValue.first ?? ToDoList()
    }
    @Published var _id: ObjectId
    @Published var title: String
    @Published var notes: String
    @Published var deadline: Date
    @Published var notification: Date
    @Published var marked: Bool
    @Published var priority: ToDo.Priotity
    @Published var list: ToDoList
    
    ///Transfer data from ToDo to ToDoModel (from data storage to UI)
    func transferToLayer(todo: ToDo)->ToDoModel{
        _id = todo._id
        title = todo.title
        notes = todo.notes
        deadline = todo.deadline
        notification = todo.notification
        marked = todo.marked
        priority = todo.priority
        list = todo.list.first!
        return self
    }
    ///Transfer data from ToDoModel to ToDo (from UI to data storage)
    func transferToRealm(todo: ToDo)->ToDo{
        todo.title = title
        todo.notes = notes
        todo.deadline = deadline != Date.isNotActive ? Date.createDeadlineTime(inputDate: deadline) : Date.isNotActive
        todo.notification = notification
        todo.marked = marked
        todo.priority = priority
        return todo
    }
}
