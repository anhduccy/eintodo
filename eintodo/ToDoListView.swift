//
//  ToDoListView.swift
//  eintodo
//
//  Created by anh :) on 17.06.22.
//

/**ToDoListView is a list for stored to-dos*/

import SwiftUI
import RealmSwift
import UniformTypeIdentifiers

struct ToDoListView: View {
    init(type: ToDoListType){
        self.type = type
    }
    @Environment(\.colorScheme) var appearance
    
    @EnvironmentObject var global: Global
    @ObservedResults(ToDo.self) var todos
    
    let type: ToDoListType
    @State var showToDoListEditView: Bool = false
    @State var showToDoEditView: Bool = false
        
    var body: some View {
        VStack{
            //Navigation Header
            VStack(spacing: 0){
                HStack(spacing: 5){
                    Text(headline())
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(type == .list ? global.selectedList.color.color : .primary)
                    Spacer()
                    
                    Button(action: {
                        showToDoEditView.toggle()
                    }, label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 100)
                                .stroke(type == .list ? global.selectedList.color.color : .blue, lineWidth: 1)
                            HStack{
                                Spacer()
                                Text("To-Do hinzufügen")
                                    .font(.system(size: 10).weight(.semibold))
                                    .foregroundColor(type == .list ? global.selectedList.color.color : .blue)
                                Spacer()
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20)
                                    .foregroundColor(type == .list ? global.selectedList.color.color : .blue)
                            }
                        }.frame(width: 130, height: 20)
                    }).buttonStyle(.plain)
                        .sheet(isPresented: $showToDoEditView){
                            ToDoEditView(global: global, isPresented: $showToDoEditView, type: .add, todo: ToDo())
                        }
                        .keyboardShortcut("n", modifiers: [.command])
                    
                    if type == .list{
                        Button(action: {
                            showToDoListEditView.toggle()
                        }, label: {
                            Image(systemName: "info.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20)
                                .foregroundColor(type == .list ? global.selectedList.color.color : .blue)
                        }).buttonStyle(.plain)
                            .sheet(isPresented: $showToDoListEditView){
                                ToDoListEditView(isPresented: $showToDoListEditView, type: .edit, list: global.selectedList)
                            }
                    }
                }
                if type == .list{
                    LeftText(text: global.selectedList.notes)
                        .foregroundColor(.gray)
                }
            }
            
            //ListView
            VStack{
                if !todos.isEmpty || !global.selectedList.todos.isEmpty{
                    ScrollView(.vertical, showsIndicators: false){
                        ForEach(returnDataSet(), id: \.self){ todo in
                            ToDoItemRow(todo: todo, type: type)
                        }
                        .padding(.top, 2.5)
                        .padding(.leading, 5)
                        .padding(.trailing, 5)
                    }
                }
            }
            Spacer()
        }.padding()
            .toolbar{
                ToolbarItemGroup(placement: .primaryAction){
                    Button("Liste hinzufügen"){
                        showToDoListEditView.toggle()
                    }
                    .sheet(isPresented: $showToDoListEditView){
                        ToDoListEditView(isPresented: $showToDoListEditView, type: .add, list: ToDoList())
                    }
                    .keyboardShortcut("n", modifiers: [.command, .option])
                    Button(global.showCompletedToDos ? "Erledigte ausblenden" : "Erledigte einblenden"){
                        withAnimation{
                            global.showCompletedToDos.toggle()
                        }
                    }
                }
            }
            .background(appearance == .dark ? ColorPalette.backgroundDarkmode : ColorPalette.backgroundLightmode)
    }
    
    //Return the data set for different List-types: Todo has a list or Todo has not a list
    private func returnDataSet()->Results<ToDo>{
        let defaultSort = [SortDescriptor(keyPath: \ToDo.completed),
                           SortDescriptor(keyPath: \ToDo.marked, ascending: false),
                           SortDescriptor(keyPath: \ToDo.priority, ascending: false),
                           SortDescriptor(keyPath: \ToDo.deadline),
                           SortDescriptor(keyPath: \ToDo.title)
                        ]
        
        let obj = ObservedRealmObject(wrappedValue: global.selectedList)
        let list = obj.wrappedValue
        
        if global.showCompletedToDos{
            switch type{
            case .all:
                return todos.sorted(by: defaultSort)
            case .date:
                return todos
                    .sorted(by: defaultSort)
                    .filter(ToDoFilter.withSelectedDateAll(d: global.selectedDate))
            case .list:
                return list.todos
                    .sorted(by: defaultSort)
            }
        } else {
            switch type {
            case .all:
                return todos
                    .sorted(by: defaultSort)
                    .filter(ToDoFilter.showNotCompleted())
            case .date:
                return todos
                    .sorted(by: defaultSort)
                    .filter(ToDoFilter.withSelectedDate(d: global.selectedDate))
            case .list:
                return list.todos
                    .sorted(by: defaultSort)
                    .filter(ToDoFilter.showNotCompleted())
            }
        }
    }
    
    private func headline()->String{
        switch type {
        case .all:
            return "Alle"
        case .date:
            if Date.isSameDay(date1: Date(), date2: global.selectedDate){
                return "Heute"
            } else if Date.isSameDay(date1: Date().addingTimeInterval(60*60*24), date2: global.selectedDate){
                return "Morgen"
            } else if Date.isSameDay(date1: Date().addingTimeInterval(-60*60*24), date2: global.selectedDate){
                return "Gestern"
            } else {
                return Date.format(displayType: "date", date: global.selectedDate)
            }
        case .list:
            return global.selectedList.title
        }
    }
}


struct ToDoItemRow: View{
    init(todo: ToDo, type: ToDoListType){
        self.todo = todo
        self.type = type
        _title = State(initialValue: todo.title)
    }
    
    @Environment(\.colorScheme) var appearance
    @EnvironmentObject var global: Global
    @State var showToDoEditView: Bool = false
    @ObservedRealmObject var todo: ToDo
    let type: ToDoListType
    
    @State var title: String

    var body: some View{
        ZStack{
            Button(action: {
                showToDoEditView.toggle()
            }, label: {
                RoundedRectangle(cornerRadius: 7.5)
                    .fill(appearance == .dark ? ColorPalette.cardDarkmode : ColorPalette.cardLightmode)
                    .shadow(color: .gray, radius: 1)
                    .onDrag{
                        NSItemProvider(object: "\(todo._id)" as NSString)
                    } preview: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 7.5)
                                .fill(.blue)
                            HStack{
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding()
                        }
                        .frame(width: 120, height: 30)
                    }
            }).buttonStyle(.plain)
                .sheet(isPresented: $showToDoEditView){
                    ToDoEditView(global: global, isPresented: $showToDoEditView, type: .edit, todo: todo)
                }
            
            HStack(spacing: 15){
                //Check box
                Button(action: {
                    $todo.completed.wrappedValue.toggle()
                }, label: {
                    Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22)
                        .foregroundColor(todo.list.first?.color.color)
                }).buttonStyle(.plain)
                //Text
                VStack{
                    HStack(alignment: .top, spacing: 2.5){
                        if todo.marked{
                            Image(systemName: "pin")
                                .foregroundColor(.red)
                        }
                        TextField("", text: $title, onEditingChanged: { _ in 
                            $todo.title.wrappedValue = title
                        })
                            .font(.body.bold())
                            .textFieldStyle(.plain)
                    }
                    .padding(.bottom, todo.marked || todo.notification != Date.isNotActive || todo.deadline != Date.isNotActive  ? -6 : 0)

                    if(todo.notification != Date.isNotActive){
                        LeftText(text: Date.format(date: todo.notification)).foregroundColor(.gray)
                    }
                    if(todo.deadline != Date.isNotActive){
                        LeftText(text: "Fällig am " + Date.format(displayType: "date", date: todo.deadline)).foregroundColor(.gray)
                    }
                }
                Spacer()
                //Status
                HStack(alignment: .center, spacing: 2.5){
                    if type != .list && !todo.list.isEmpty {
                        ToDoItemRowSymbol(systemName: todo.list.first!.symbol, color: todo.list.first!.color.color)
                    }
                    if todo.priority != .none{
                        ToDoItemRowSymbol(systemName: todo.priority.systemName, color: .blue)
                    }
                    if todo.notes != ""{
                        ToDoItemRowSymbol(systemName: "text.alignleft", color: .gray)
                    }
                    Button(action: {
                        ToDo.delete(todo: todo)
                    }, label: {
                        ToDoItemRowSymbol(systemName: "trash", color: .red)
                    }).buttonStyle(.plain)
                }
            }
            .padding(.top, 12.5)
            .padding(.bottom, 12.5)
            .padding(.leading, 15)
            .padding(.trailing, 10)
        }
    }
}

struct ToDoItemRowSymbol: View{
    let systemName: String
    let color: Color
    var body: some View{
        ZStack(alignment: .center){
            Circle().fill(.clear)
                .frame(width: 20, height: 20)
            Image(systemName: systemName)
                .foregroundColor(color)
        }
    }
}
