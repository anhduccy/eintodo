//
//  DropDelegates.swift
//  eintodo
//
//  Created by anh :) on 05.07.22.
//

import SwiftUI
import RealmSwift

///Drop-Destination "Benutzerdefinierte Listen" für To-Dos
struct ToDoListCollectionRowDropDelegate: DropDelegate{
    let global: Global
    let list: ToDoList
    func performDrop(info: DropInfo) -> Bool {
        if let item = info.itemProviders(for: ["public.utf8-plain-text"]).first {
            item.loadItem(forTypeIdentifier: "public.utf8-plain-text"){ (data, error) in
                if let data = data as? Data{
                    let identifierStr = String(decoding: data, as: UTF8.self)
                    let identifier = try! ObjectId(string: identifierStr)
                    
                    DispatchQueue.main.async {
                        let todo = realmEnv.objects(ToDo.self).filter(NSPredicate(format: "_id == %@", identifier)).first!
                        let model = ToDoModel().transferToLayer(todo: todo)
                        model.list = list
                        
                        ToDo.update(todo: ObservedRealmObject(wrappedValue: todo).projectedValue, model: model)
                    }
                    Task {
                        global.selectedList = list
                    }
                }
            }
            return true
        } else {
            return false
        }
    }
}

///Drop-Destination "Kalender" für To-Dos
struct ToDoCalendarViewDropDelegate: DropDelegate{
    let global: Global
    let date: Date
    func performDrop(info: DropInfo) -> Bool {
        if let item = info.itemProviders(for: ["public.utf8-plain-text"]).first {
            item.loadItem(forTypeIdentifier: "public.utf8-plain-text"){ (data, error) in
                if let data = data as? Data{
                    let identifierStr = String(decoding: data, as: UTF8.self)
                    let identifier = try! ObjectId(string: identifierStr)
                    
                    DispatchQueue.main.async {
                        let todo = realmEnv.objects(ToDo.self).filter(NSPredicate(format: "_id == %@", identifier)).first!
                        
                        try! realmEnv.write{
                            let model = ToDoModel().transferToLayer(todo: todo)
                            model.deadline = Date.createDeadlineTime(inputDate: date)
                            ToDo.update(todo: ObservedRealmObject(wrappedValue: todo).projectedValue, model: model)
                        }
                    }
                    Task {
                        global.selectedDate = date
                    }
                }
            }
            return true
        } else {
            return false
        }
    }
}
