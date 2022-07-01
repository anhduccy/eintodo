//
//  SettingsView.swift
//  eintodo
//
//  Created by anh :) on 30.06.22.
//

import SwiftUI
import RealmSwift

struct SettingsView: View {
    init(){
        let timeStr = UserDefaults.standard.string(forKey: "deadlineTime")
        if timeStr == nil {
            UserDefaults.standard.set("09:00", forKey: "deadlineTime")
        }
        let df = DateFormatter()
        df.dateFormat = "DD-MM-YYYY"
        let currentDate = df.string(from: Date())
        df.dateFormat = "DD-MM-YYYY, HH:mm"
        let date = df.date(from: "\(currentDate), \(timeStr!)")
        _deadlineTime = State(initialValue: date!)
    }
    @State var deadlineTime: Date
    var body: some View {
        VStack{
            HStack{
                Text("Uhrzeit für Benachrichtigungen")
                DatePicker("", selection: $deadlineTime, displayedComponents: [.hourAndMinute])
                    .onChange(of: deadlineTime){ _ in
                        storeDeadlineTime()
                    }
                Spacer()
            }
            Spacer()
        }.padding()
            .frame(width: 400, height: 500)
            .navigationTitle("Einstellungen")
    }
    private func storeDeadlineTime(){
        let time = Date.format(displayType: "time", date: deadlineTime)
        let defaults = UserDefaults.standard
        defaults.set(time, forKey: "deadlineTime")
        
        let todos = realmEnv.objects(ToDo.self)
        
        for todo2 in todos{
            let todo = ObservedRealmObject(wrappedValue: todo2).projectedValue
            let model = ToDoModel().transferToLayer(todo: todo2)
            if model.deadline != Date.isNotActive{
                model.deadline =  Date.createDeadlineTime(inputDate: todo.deadline.wrappedValue)
            }
            ToDo().update(todo: todo, model: model)
        }
    }
}
