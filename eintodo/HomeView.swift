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
    @State var showSettingsView: Bool = false
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
                            Text("\(todos.filter(ToDoFilter.showNotCompleted()).count)")
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
            .toolbar{
                ToolbarItemGroup(placement: .automatic){
                    Button(action: {
                        showSettingsView.toggle()
                    }, label: {
                        Image(systemName: "gear")
                    }).sheet(isPresented: $showSettingsView){
                        SettingsView(isPresented: $showSettingsView)
                    }
                    .keyboardShortcut(",", modifiers: [.command])
                }
            }
        }
        .onAppear{
            try! realmEnv.write{
                initDefaultList(global: global, lists: $lists)
            }
        }
        .frame(minWidth: 200)
    }
}

func initDefaultList(global: Global, lists: ObservedResults<ToDoList>){
    if lists.wrappedValue.isEmpty{
        let model = ToDoListModel(title: "Neue Liste", notes: "Liste, um Erinnerungen hinzuzufügen", symbol: "list.bullet", color: .blue)
        global.selectedList = ToDoList.add(lists: lists, model: model)
    } else {
        global.selectedList = lists.wrappedValue.first!
    }
}
