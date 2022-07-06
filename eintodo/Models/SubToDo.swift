//
//  SubToDo.swift
//  eintodo
//
//  Created by anh :) on 06.07.22.
//

import Foundation
import RealmSwift

///Sub-To-Do-Model for Realm/MongoDB
class SubToDo: Object, ObjectKeyIdentifiable{
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var title: String
    @Persisted var completed: Bool = false
    @Persisted(originProperty: "subToDos") var todo: LinkingObjects<ToDo>
    
    //FUNCTIONS
    ///Add a sub to-do with a sub to-do-model layer to a to-do in Realm/MongoDB.
    static func add(todo: ToDo, model: SubToDoModel){
        try? realmEnv.write{
            let obj = realmEnv.objects(ToDo.self).filter(NSPredicate(format: "_id == %@", todo._id)).first!
            obj.subToDos.append(model.transferToRealm(subToDo: SubToDo()))
        }
    }
    ///Update a sub to-do with a sub to-do-model layer in Realm/MongoDB
    static func update(subToDo: ObservedRealmObject<SubToDo>.Wrapper, model: SubToDoModel){
        if subToDo.wrappedValue.todo.first?._id == model.todo._id{
            subToDo.title.wrappedValue = model.title
        } else {
            try! realmEnv.write{
                let store = SubToDo(value: subToDo.wrappedValue)
                realmEnv.delete(realmEnv.objects(SubToDo.self).filter("_id == %@", subToDo.wrappedValue._id))
                let todo = realmEnv.objects(ToDo.self).filter(NSPredicate(format: "_id == %@", model.todo._id)).first!
                ObservedRealmObject(wrappedValue: todo).projectedValue.subToDos.append(model.transferToRealm(subToDo: store))
            }
        }
    }
    ///Delete a sub to-do from Realm/MongoDB
    static func delete(subToDo: SubToDo){
        try! realmEnv.write{
            realmEnv.delete(realmEnv.objects(SubToDo.self).filter("_id = %@", subToDo._id))
        }
    }
}

///A model layer between data storage (Realm/MongoDB) and UI for type SubToDo
class SubToDoModel: ObservableObject{
    init(){
        _id = ObjectId()
        title = ""
        completed = false
        let todos = ObservedResults(ToDo.self)
        todo = todos.wrappedValue.first ?? ToDo()
        status = .noStatus
    }
    @Published var _id: ObjectId
    @Published var title: String
    @Published var completed: Bool
    @Published var todo: ToDo
    @Published var status: SubToDoStatus
    
    ///Transfer data from SubToDo to SubToDoModel (from data storage to UI)
    func transferToLayer(subToDo: SubToDo)->SubToDoModel{
        _id = subToDo._id
        title = subToDo.title
        todo = subToDo.todo.first!
        completed = subToDo.completed
        return self
    }
    ///Transfer data from SubToDoModel to SubToDo (from UI to data storage)
    func transferToRealm(subToDo: SubToDo)->SubToDo{
        subToDo.title = title
        return subToDo
    }
    
    convenience init(title: String){
        self.init()
        self.title = title
    }
}

enum SubToDoStatus{
    case noStatus, add, update, delete
}
