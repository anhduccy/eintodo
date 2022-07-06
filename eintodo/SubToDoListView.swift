//
//  SubToDoListView.swift
//  eintodo
//
//  Created by anh :) on 06.07.22.
//

import Foundation
import SwiftUI
import RealmSwift

struct SubToDoListView: View{
    @ObservedResults(SubToDo.self) var subToDos
    @ObservedRealmObject var todo: ToDo
    
    @State var subToDosLayerStorage: [SubToDoModel] = []
    @State var title: String = ""
    
    var body: some View{
        VStack(spacing: 10){
            HStack{
                TextField("Untergeordenete Erinnerung hinzufügen", text: $title)
                    .font(.title2.weight(.semibold))
                    .textFieldStyle(.plain)
                Spacer()
                Button(action: {
                    let newItem = SubToDoModel(title: title)
                    newItem.status = .add
                    subToDosLayerStorage.append(newItem)
                    title = ""
                }, label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable().scaledToFit()
                        .frame(width: 15)
                        .foregroundColor(todo.list.first?.color.color ?? .blue)
                }).buttonStyle(.plain)
            }
            VStack(spacing: 5){
                ForEach(subToDosLayerStorage.indices, id: \.self){ i in
                    SubToDoListRow(storage: $subToDosLayerStorage, todo: todo, subToDo: subToDosLayerStorage[i])
                }
            }
        }
        //Load all Realm objects into the UI as a new array
        .onAppear{
            for subToDo in todo.subToDos{
                let sub = SubToDoModel().transferToLayer(subToDo: subToDo)
                subToDosLayerStorage.append(sub)
            }
        }
        //Submit all changes from the UI to Realm objects
        .onDisappear{
            for subToDo in subToDosLayerStorage{
                let realmObj = subToDos.filter(NSPredicate(format: "_id == %@", subToDo._id)).first ?? SubToDo()
                
                switch subToDo.status{
                case .add: SubToDo.add(todo: todo, model: subToDo)
                case .update:
                    let observedObj = ObservedRealmObject(wrappedValue: realmObj).projectedValue
                    SubToDo.update(subToDo: observedObj, model: subToDo)
                case .delete:
                    SubToDo.delete(subToDo: realmObj)
                case .noStatus:
                    continue
                }
            }
        }
    }
}

struct SubToDoListRow: View{
    init(storage: Binding<[SubToDoModel]>, todo: ToDo, subToDo: SubToDoModel){
        _storage = storage
        self.todo = todo
        self.model = subToDo
    }
    
    @Binding var storage: [SubToDoModel]
    @ObservedRealmObject var todo: ToDo
    @ObservedObject var model: SubToDoModel
    
    var body: some View{
        if model.status != .delete{
            HStack{
                Button(action: {
                    model.completed.toggle()
                    model.status = .update
                }, label: {
                    Image(systemName: model.completed ? "checkmark.circle.fill" : "circle")
                        .resizable().scaledToFit()
                        .frame(width: 15)
                        .foregroundColor(model.completed ? todo.list.first?.color.color : .gray)
                        .opacity(model.completed ? 1 : 0.5)
                }).buttonStyle(.plain)
                    .disabled(model.status == .add)
                
                TextField("Untergeordnete Erinnerungen", text: $model.title, onEditingChanged: { _ in
                    if model.status != .add{
                        model.status = .update
                    }
                })
                    .textFieldStyle(.plain)
                Spacer()
                Button(action: {
                    model.status = .delete
                }, label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }).buttonStyle(.plain)
            }
        }
    }
}
