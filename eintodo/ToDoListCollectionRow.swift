//
//  ToDoListCollectionRow.swift
//  eintodo
//
//  Created by anh :) on 19.06.22.
//

/**ToDoListCollectionRow - A row which is displayed on the left hand side in the sidebar. The user can access through the row to their individual created lists**/

import SwiftUI

struct ToDoListCollectionRow: View{
    @EnvironmentObject var global: Global
    let viewIndex: Int
    let list: ToDoList
    @State var showToDoListEditView: Bool = false
    @State var overItem: Bool = false
    var body: some View{
        HStack{
            SystemIcon(systemName: list.symbol, size: 20, color: list.color.color)
            Text(list.title)
                .foregroundColor(viewIndex == global.selectedView ? .white : list.color.color)
            Spacer()
            Text("\(list.todos.filter(ToDoFilter().showNotCompleted()).count)")
                .foregroundColor(viewIndex == global.selectedView ? .white : list.color.color)
            if overItem{
                Button(action: {
                    showToDoListEditView.toggle()
                }, label: {
                    Image(systemName: "info.circle").foregroundColor(viewIndex == global.selectedView ? .white : list.color.color)
                }).buttonStyle(.plain)
                .sheet(isPresented: $showToDoListEditView){
                    ToDoListEditView(isPresented: $showToDoListEditView, type: .edit, list: list)
                }
            }
        }.onHover{ over in
            withAnimation{
                if !showToDoListEditView{
                    overItem = over
                }
            }
        }
    }
}

