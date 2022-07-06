
//  ToDoEditView.swift
//  eintodo
//
//  Created by anh :) on 17.06.22.
//

/**ToDoEditView is a sheet where user can edit their to-do*/

import SwiftUI
import RealmSwift

struct ToDoEditView: View{
    init(global: Global, isPresented: Binding<Bool>, type: EditViewType, todo: ToDo){
        _isPresented = isPresented
        self.type = type
        self.todo = todo
        if todo.title != ""{
            _model = StateObject(wrappedValue: ToDoModel().transferToLayer(todo: todo))
        } else {
            //Automatic list assignment when a new to-do is created
            let model = ToDoModel()
            model.list = global.selectedList.title == "" ? realmEnv.objects(ToDoList.self).first! : global.selectedList
            _model = StateObject(wrappedValue: model)
        }
    }
    @EnvironmentObject var global: Global
    
    @ObservedRealmObject var todo: ToDo
    @StateObject var model: ToDoModel
    
    @Binding var isPresented: Bool
    let type: EditViewType
    
    @State var showListPickerPopover: Bool = false
    @State var showPriorityPickerPopover: Bool = false
        
    var body: some View{
        VStack(spacing: 20){
            //List Picker Popover
            HStack{
                Button(action: {
                    showListPickerPopover.toggle()
                }, label: {
                    HStack{
                        SystemIcon(systemName: model.list.symbol, size: 25, color: model.list.color.color)
                        Text(model.list.title).foregroundColor(model.list.color.color)
                    }
                }).popover(isPresented: $showListPickerPopover){
                    ToDoListPickerPopover(isPresented: $showListPickerPopover, model: model)
                }.buttonStyle(.plain)
                Spacer()
            }
            
            VStack(spacing: 2){
                TextField("Titel", text: $model.title)
                    .textFieldStyle(.plain)
                    .font(.title.bold())
                TextField("Notizen", text: $model.notes)
                    .textFieldStyle(.plain)
                    .foregroundColor(.gray)
            }
            Divider()
            
            ScrollView(.vertical, showsIndicators: false){
                //Attributes
                VStack(spacing: 10){
                    //Deadline
                    SystemDatePicker(displayType: "date", date: $model.deadline, title: "Deadline", systemName: "calendar", size: 27.5, color: model.list.color.color)
        
                    //Notification
                    SystemDatePicker(date: $model.notification, title: "Erinnerung", systemName: "bell", size: 27.5, color: model.list.color.color)
                    
                    //Priorities
                    HStack(alignment: .center){
                        Button(action: {
                            showPriorityPickerPopover.toggle()
                        }, label: {
                            SystemIcon(isActive: model.priority == ToDo.Priotity.none ? false : true, systemName: $model.priority.wrappedValue.systemName, size: 27.5, color: model.list.color.color)
                        }).buttonStyle(.plain)
                            .popover(isPresented: $showPriorityPickerPopover){
                                ToDoPriorityPickerPopover(isPresented: $showPriorityPickerPopover, model: model)
                            }
                        Text("Priorität")
                        Spacer()
                        Text(model.priority.text)
                            .foregroundColor(model.priority.text == "Keine" ? .gray : model.list.color.color)
                            .opacity(model.priority.text == "Keine" ? 0.5 : 1)
                    }
                    
                    //IsMarked
                    HStack(alignment: .center){
                        Button(action: {
                            withAnimation{
                                model.marked.toggle()
                            }
                        }, label: {
                            SystemIcon(isActive: model.marked, systemName: "pin", size: 27.5, color: .red)
                        }).buttonStyle(.plain)
                        Text("Markiert")
                        Spacer()
                        if model.marked{
                            Text("Markiert")
                                .foregroundColor(.red)
                        } else {
                            Text("Nicht markiert")
                                .foregroundColor(.gray)
                                .opacity(0.5)
                        }
                    }
                }
                
                //Sub To-Dos
                SubToDoListView(todo: todo)
                    .padding(.top, 5)

                Spacer()
            }
            
            //Dismiss Bar
            HStack{
                Button("Abbrechen"){
                    isPresented.toggle()
                }
                .foregroundColor(.red)
                .buttonStyle(.plain)
                if type == .edit{
                    Spacer()
                    Button(action: {
                        ToDo.delete(todo: todo)
                    }, label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }).buttonStyle(.plain)
                }
                Spacer()
                Button("Fertig"){
                    if type == .add{
                        ToDo.add(list: model.list, model: model)
                    } else {
                        ToDo.update(todo: $todo, model: model)
                    }
                    isPresented.toggle()
                }
                .font(.body.bold())
                .foregroundColor(.blue)
                .buttonStyle(.plain)
                .disabled(model.title.isEmpty)
            }
        }.padding()
            .frame(minWidth: 400, idealWidth: 400, maxWidth: 400, minHeight: 350, idealHeight: 500, maxHeight: 700)
            .background(.ultraThinMaterial)
    }
}

struct ToDoListPickerPopover: View{
    @EnvironmentObject var global: Global
    @ObservedResults(ToDoList.self) var lists
    @Binding var isPresented: Bool
    @StateObject var model: ToDoModel
    
    init(isPresented: Binding<Bool>, model: ToDoModel){
        _isPresented = isPresented
        _model = StateObject(wrappedValue: model)
    }
    
    var body: some View{
        VStack(spacing: 10){
            Text("Liste auswählen").font(.title2.bold())
            VStack(spacing: 5){
                ForEach(lists, id: \.self){ list in
                    Button(action: {
                        model.list = list
                    }, label: {
                        HStack{
                            Image(systemName: model.list._id == list._id ? "checkmark.circle" : "circle")
                                .foregroundColor(list.color.color)
                            Text(list.title)
                            Spacer()
                        }
                    }).buttonStyle(.plain)
                }
            }
        }.padding()
    }
}

struct ToDoPriorityPickerPopover: View{
    init(isPresented: Binding<Bool>, model: ToDoModel){
        _isPresented = isPresented
        _model = StateObject(wrappedValue: model)
    }
    @Binding var isPresented: Bool
    @StateObject var model: ToDoModel
    var body: some View{
        VStack{
            Text("Priorität auswählen").font(.title2.bold())
            
            Picker("", selection: $model.priority){
                ForEach(ToDo.Priotity.allCases, id: \.self){ prio in
                    Text(prio.text).tag(prio)
                }
            }.pickerStyle(.radioGroup)
        }.padding()
    }
}
