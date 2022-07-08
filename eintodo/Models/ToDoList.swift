//
//  ToDoList.swift
//  eintodo
//
//  Created by anh :) on 19.06.22.
//

import SwiftUI
import RealmSwift

///To-Do-List-Model for Realm/MongoDB
class ToDoList: Object, ObjectKeyIdentifiable{
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var title: String
    @Persisted var notes: String
    @Persisted var symbol: String
    @Persisted var color: Colors
    @Persisted var sortIndex: Int
    @Persisted var todos: RealmSwift.List<ToDo>
    
    enum Colors: Int, PersistableEnum{
        case pink, red, orange, yellow, green, mint, cyan, teal, blue, indigo, purple, brown, gray, black
        
        var color: Color{
            
            switch self{
            case .pink: return .pink
            case .red: return .red
            case .orange: return .orange
            case .yellow: return .yellow
            case .green: return .green
            case .mint: return .mint
            case .teal: return .teal
            case .cyan: return .cyan
            case .blue: return .blue
            case .indigo: return .indigo
            case .purple: return .purple
            case .brown: return .brown
            case .gray: return .gray
            case .black: return .black
            }
        }
    }
    
    //Functions
    ///Add a to-do-list with a to-do-list-model layer to Realm/MongoDB
    static func add(lists: ObservedResults<ToDoList>, model: ToDoListModel)->ToDoList{
        let list = ToDoList()
        list.title = model.title
        list.notes = model.notes
        list.symbol = model.symbol
        list.color = model.color
        list.sortIndex = lists.wrappedValue.count == 0 ? 0 : lists.wrappedValue.count
        lists.append(list)
        return list
    }
    ///Update a to-do-list with a to-do-list-model layer in Realm/MongoDB
    static func update(list: ObservedRealmObject<ToDoList>.Wrapper, model: ToDoListModel){
        list.title.wrappedValue = model.title
        list.notes.wrappedValue = model.notes
        list.symbol.wrappedValue = model.symbol
        list.color.wrappedValue = model.color
    }
    ///Delete a to-do-list from Realm/MongoDB
    static func delete(list: ToDoList){
        let realmList = realmEnv.objects(ToDoList.self).filter("_id == %@", list._id).first!
        try! realmEnv.write{
            for todo in realmList.todos{
                ToDo.delete(todo: todo)
            }
            realmEnv.delete(realmList)
        }
    }
}

///A model layer between data storage (Realm/MongoDB) and UI for type ToDoList
class ToDoListModel: ObservableObject{
    init(){
        _id = ObjectId()
        title = ""
        notes = ""
        symbol = "list.bullet"
        color = .blue
    }
    @Published var _id: ObjectId
    @Published var title: String
    @Published var notes: String
    @Published var symbol: String
    @Published var color: ToDoList.Colors
    
    ///Create the opportunity to initialize a ToDoListModel with its initializier
    convenience init(title: String, notes: String, symbol: String, color: ToDoList.Colors){
        self.init()
        self.title = title
        self.notes = notes
        self.symbol = symbol
        self.color = color
    }
    ///Transfer data from ToDoList to ToDoListModel (from data storage to UI)
    func transferToLayer(list: ToDoList)->ToDoListModel{
        _id = list._id
        title = list.title
        notes = list.notes
        symbol = list.symbol
        color = list.color
        return self
    }
    ///Transfer data from ToDoListModel to ToDoList (from UI to data storage)
    func transferToRealm(list: ToDoList)->ToDoList{
        list.title = title
        list.notes = notes
        list.symbol = symbol
        list.color = color
        return list
    }
}
