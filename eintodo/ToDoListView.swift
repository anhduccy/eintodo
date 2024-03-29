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
    
    let windowSize: CGFloat = 400
    
    @State var onHoverAddButton: Bool = false
        
    var body: some View {
        ZStack(alignment: .bottomTrailing){
            VStack(spacing: 10){
                //Navigation Header
                VStack(spacing: 0){
                    VStack(spacing: 5){
                        HStack(spacing: 10){
                            Text(headline())
                                .font(.largeTitle.weight(.bold))
                                .foregroundColor(type == .list ? global.selectedList.color.color : .primary)
                            Spacer()
                            
                            HStack(spacing: 5){
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
                            
                            if !returnDataSet(type: type, showCompletedToDos: true).isEmpty{
                                if calculateProgress() != 1 {
                                    //Progress-Circle
                                        ZStack{
                                            Circle()
                                                .stroke(lineWidth: 5)
                                                .opacity(0.2)
                                            Circle()
                                                .trim(from: 0.0, to: calculateProgress())
                                                .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                                                .rotationEffect(Angle(degrees: 270))
                                        }
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(type == .list ? global.selectedList.color.color : .blue)
                                }
                            }
                        }
                        HStack{
                            if type == .list{
                                LeftText(text: global.selectedList.notes)
                                    .foregroundColor(.gray)
                            } else {
                                LeftText(text: "Alle Erinnerungen auf einem Blick")
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button(action: {
                                global.showCompletedToDos.toggle()
                            }, label: {
                                Text(global.showCompletedToDos ? "Erledigte ausblenden" : "Erledigte einblenden")
                                    .foregroundColor(type == .list ? global.selectedList.color.color : .blue)
                            }).buttonStyle(.plain)
                        }
                    }
                }
                
                //ListView
                VStack{
                    if (!returnDataSet(type: type, showCompletedToDos: true).isEmpty && !global.showCompletedToDos) && returnDataSet(type: type, showCompletedToDos: false).isEmpty{
                        VStack{
                            Spacer()
                            HStack{
                                Spacer()
                                Image(systemName: "checkmark")
                                    .foregroundColor(type == .list ? global.selectedList.color.color : .blue)
                                Text("Du hast alle Erinnerungen erledigt")
                                    .foregroundColor(.gray)
                                    .opacity(0.75)
                                Spacer()
                            }
                            Spacer()
                        }
                    } else if (!returnDataSet(type: type, showCompletedToDos: true).isEmpty && global.showCompletedToDos) || !returnDataSet(type: type, showCompletedToDos: false).isEmpty{
                        ScrollView(.vertical, showsIndicators: false){
                            ForEach(returnDataSet(type: type, showCompletedToDos: global.showCompletedToDos), id: \.self){ todo in
                                ToDoItemRow(todo: todo, type: type)
                            }
                            .padding(.top, 2.5)
                            .padding(.leading, 5)
                            .padding(.trailing, 5)
                        }
                    } else {
                        VStack{
                            Spacer()
                            HStack{
                                Spacer()
                                Text("Keine Erinnerungen vorhanden")
                                    .foregroundColor(.gray)
                                    .opacity(0.75)
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                }
                Spacer()
            }
            Button(action: {
                showToDoEditView.toggle()
            }, label: {
                ZStack{
                    Circle().fill(type == .list ? global.selectedList.color.color : .blue)
                        .frame(width: 39, height: 39)
                        .shadow(color: onHoverAddButton ? (type == .list ? global.selectedList.color.color : .blue) : .gray, radius: 2)
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                        .foregroundColor(appearance == .dark ? ColorPalette.cardDarkmode : ColorPalette.backgroundLightmode)
                }
            }).buttonStyle(.plain)
                .sheet(isPresented: $showToDoEditView){
                    ToDoEditView(global: global, isPresented: $showToDoEditView, listType: type, editViewType: .add, todo: ToDo())
                }
                .keyboardShortcut("n", modifiers: [.command])
                .onHover{ over in
                    withAnimation{
                        onHoverAddButton = over
                    }
                }
        }
        .padding()
        .background(appearance == .dark ? ColorPalette.backgroundDarkmode : ColorPalette.backgroundLightmode)
        .frame(minWidth: windowSize)
    }
    
    private func calculateProgress()->CGFloat{
        withAnimation{
            let pendingToDos = returnDataSet(type: type, showCompletedToDos: false).count
            let allToDos = returnDataSet(type: type, showCompletedToDos: true).count
            let factor = 1.0 - (Double(pendingToDos) / Double(allToDos))
            return factor
        }
    }
    
    ///Return the data set for different List-types: Todo has a list or Todo has not a list
    private func returnDataSet(type: ToDoListType, showCompletedToDos: Bool)->Results<ToDo>{
        let defaultSort = [SortDescriptor(keyPath: \ToDo.completed),
                           SortDescriptor(keyPath: \ToDo.marked, ascending: false),
                           SortDescriptor(keyPath: \ToDo.priority, ascending: false),
                           SortDescriptor(keyPath: \ToDo.deadline),
                           SortDescriptor(keyPath: \ToDo.title)
                        ]
        
        let obj = ObservedRealmObject(wrappedValue: global.selectedList)
        let list = obj.wrappedValue
        
        if showCompletedToDos{
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
    
    @State var onHover: Bool = false
    
    @State var title: String

    var body: some View{
        ZStack{
            Button(action: {
                showToDoEditView.toggle()
            }, label: {
                RoundedRectangle(cornerRadius: 7.5)
                    .fill(appearance == .dark ? ColorPalette.cardDarkmode : ColorPalette.cardLightmode)
                    .shadow(color: onHover ? (todo.list.first?.color.color ?? .blue) : .gray, radius: onHover ? 2 : 1)
                    .onDrag{
                        NSItemProvider(object: "\(todo._id)" as NSString)
                    } preview: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 5)
                                .fill(todo.list.first?.color.color ?? .blue)
                            HStack{
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.leading, 7.5)
                            .padding(5)
                        }
                        .frame(width: 90, height: 30)
                    }
            }).buttonStyle(.plain)
                .sheet(isPresented: $showToDoEditView){
                    ToDoEditView(global: global, isPresented: $showToDoEditView, listType: type, editViewType: .edit, todo: todo)
                }
            VStack{
                HStack(spacing: 15){
                    //Check box
                    Button(action: {
                        withAnimation{
                            $todo.completed.wrappedValue.toggle()
                        }
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
                                if title == ""{
                                    ToDo.delete(todo: todo)
                                } else {
                                    $todo.title.wrappedValue = title
                                }
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
                if !todo.subToDos.isEmpty{
                        VStack(spacing: 1){
                            ForEach(todo.subToDos, id: \.self){ subToDo in
                                ToDoItemRowSubToDoRow(subToDo: subToDo)
                            }
                        }
                        .padding(.top, -5)
                        .padding(.leading, 35)
                }
            }
            .padding(.top, 12.5)
            .padding(.bottom, 12.5)
            .padding(.leading, 15)
            .padding(.trailing, 10)
        }
        .onHover{ over in
            withAnimation{
                onHover = over
            }
        }
    }
}

struct ToDoItemRowSubToDoRow: View{
    init(subToDo: SubToDo){
        self.subToDo = subToDo
        _title = State(initialValue: subToDo.title)
    }
    @ObservedRealmObject var subToDo: SubToDo
    
    @State var title: String
    
    var body: some View{
        HStack(spacing: 5){
            Button(action: {
                withAnimation{
                    $subToDo.completed.wrappedValue.toggle()
                }
            }, label: {
                Image(systemName: subToDo.completed ? "checkmark.circle" : "circle")
                    .foregroundColor(subToDo.todo.first?.list.first?.color.color ?? .blue)
            }).buttonStyle(.plain)
            TextField("Titel", text: $title, onEditingChanged: { _ in
                if title == ""{
                    SubToDo.delete(subToDo: subToDo)
                } else {
                    $subToDo.title.wrappedValue = title
                }
                  })
                .textFieldStyle(.plain)
                .foregroundColor(.gray)
            Spacer()
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
