//
//  HomeView.swift
//  eintodo
//
//  Created by anh :) on 21.06.22.
//

import SwiftUI
import RealmSwift

struct HomeView: View {
    @EnvironmentObject var global: Global
    @ObservedResults(ToDoList.self) var lists
    @ObservedResults(ToDo.self) var todos
    
    @State var showToDoListEditView: Bool = false
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Start")){
                    NavigationLink(tag: 0, selection: $global.selectedView) {
                        CalendarView()
                    } label: {
                        Label("Kalender", systemImage: "calendar")
                    }
                }
                
                Section(header: Text("Sortierte Listen")){
                    NavigationLink(tag: 1, selection: $global.selectedView) {
                        ToDoListView(type: .all)
                            .onAppear{
                                global.selectedDate = Date()
                            }
                    } label: {
                        HStack{
                            Label("Alle", systemImage: "tray")
                            Spacer()
                            Text("\(todos.filter(ToDoFilter().showNotCompleted()).count)")
                        }
                    }
                }
                
                Section(header: Text("Meine Listen")){
                    ForEach(lists.indices, id: \.self){ i in
                        NavigationLink(
                            destination: ToDoListView(type: .list)
                                .onAppear{
                                    global.selectedList = lists[i]
                                    global.selectedDate = Date()
                                },
                            tag: i + 2,
                            selection: $global.selectedView
                        ){
                            ToDoListCollectionRow(viewIndex: i + 2, list: lists[i])
                        }
                    }
                }
            }
            .listStyle(.sidebar)
        }
        .onAppear{
            try! realmEnv.write{
                initDefaultList(global: global, lists: $lists)
            }
            let defaults = UserDefaults.standard
            defaults.set("15:00", forKey: "deadlineTime")
        }
        .frame(minWidth: 200)
        .toolbar{
            ToolbarItem{
                Button("Liste hinzufügen"){
                    showToDoListEditView.toggle()
                }
                .sheet(isPresented: $showToDoListEditView){
                    ToDoListEditView(isPresented: $showToDoListEditView, type: .add, list: ToDoList())
                }
                .keyboardShortcut("n", modifiers: [.command, .option])
            }
            ToolbarItem{
                Button(global.showCompletedToDos ? "Erledigte ausblenden" : "Erledigte einblenden"){
                    withAnimation{
                        global.showCompletedToDos.toggle()
                    }
                }
            }
        }
    }
}

func initDefaultList(global: Global, lists: ObservedResults<ToDoList>){
    if lists.wrappedValue.isEmpty{
        let model = ToDoListModel(title: "Neue Liste", notes: "Liste, um Erinnerungen hinzuzufügen", symbol: "list.bullet", color: .blue)
        global.selectedList = ToDoList().add(lists: lists, model: model)
    } else {
        global.selectedList = lists.wrappedValue.first!
    }
}
