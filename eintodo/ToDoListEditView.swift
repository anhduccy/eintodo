//
//  ToDoListEditView.swift
//  eintodo
//
//  Created by anh :) on 19.06.22.
//

/**ToDoListEditView - A view where users can edit their To-Do-List**/

import SwiftUI
import RealmSwift

struct ToDoListEditView: View{
    init(isPresented: Binding<Bool>, type: EditViewType, list: ToDoList){
        _isPresented = isPresented
        self.type = type
        self.list = list
        if list.title != ""{
            _model = StateObject(wrappedValue: ToDoListModel().transferToLayer(list: list))
        } else {
            _model = StateObject(wrappedValue: ToDoListModel())
        }
    }
    @EnvironmentObject var global: Global
    
    @ObservedResults(ToDoList.self) var lists
    @ObservedRealmObject var list: ToDoList
    
    @Binding var isPresented: Bool
    
    let type: EditViewType
    @StateObject var model: ToDoListModel
    
    let symbolsGrid: [GridItem] = Array(repeating: .init(.fixed(30)), count: 10)
    let colorsGrid: [GridItem] = Array(repeating: .init(.fixed(40)), count: 7)
    
    var body: some View{
        VStack{
            TextField("Liste", text: $model.title)
                .font(.largeTitle.bold())
                .textFieldStyle(.plain)
                .foregroundColor(model.color.color)
            TextField("Beschreibung", text: $model.notes)
                .foregroundColor(.gray)
                .textFieldStyle(.plain)
            
            Spacer()
            
            //Preview
            HStack{
                Spacer()
                SystemIcon(systemName: model.symbol, size: 60, color: model.color.color)
                    .animation(.interactiveSpring(), value: model.symbol)
                    .animation(.default, value: model.color)
                Spacer()
            }
            
            Spacer()
            //List color
            LazyVGrid(columns: colorsGrid){
                ForEach(0..<ToDoList.Colors.allCases.count, id: \.self){ c in
                    Button(action: {
                        withAnimation{
                            model.color = ToDoList.Colors(rawValue: c)!
                        }
                    }, label: {
                        ZStack{
                            Circle().foregroundColor(ToDoList.Colors(rawValue: c)?.color)
                                .frame(width: 35, height: 35)
                            if model.color.color == ToDoList.Colors(rawValue: c)?.color{
                                Image(systemName: "circle.fill")
                                    .foregroundColor(.white)
                            }
                        }
                    }).buttonStyle(.plain)
                }
            }
            
            Spacer()
            
            //List symbol
            LazyVGrid(columns: symbolsGrid){
                ForEach(SymbolCatalog.s, id: \.self){ symbol in
                    Button(action: {
                        model.symbol = symbol
                    }, label: {
                        SystemIcon(isActive: model.symbol == symbol ? true : false, systemName: symbol, size: 30, color: model.color.color)
                    }).buttonStyle(.plain)
                }
            }
            
            Spacer()
            
            HStack{
                Button("Abbrechen"){isPresented.toggle()}
                    .buttonStyle(.plain)
                    .foregroundColor(.red)
                //Delete button
                if type == .edit{
                    Spacer()
                    Button(action: {
                        for todo in list.todos{
                            ToDo().delete(todo: todo)
                        }
                        ToDoList().delete(list: list)
                        initDefaultList(global: global, lists: $lists)
                        global.selectedList = realmEnv.objects(ToDoList.self).first!
                        global.selectedView = lists.count + 1
                        isPresented.toggle()
                    }, label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }).buttonStyle(.plain)
                }
                Spacer()
                Button("Fertig"){
                    if type == .add{
                        global.selectedList = ToDoList().add(lists: $lists, model: model)
                        global.selectedView = global.selectedList.sortIndex + 2
                    } else {
                        ToDoList().update(list: $list, model: model)
                        global.selectedList = list
                    }
                    isPresented.toggle()
                }.font(.body.bold())
                    .foregroundColor(model.title.isEmpty ? .primary : .blue)
                .buttonStyle(.plain)
                .disabled(model.title.isEmpty)
            }
        }.frame(width: 400, height: 500)
            .padding()
            .background(.ultraThinMaterial)
    }
}
