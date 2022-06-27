//
//  ContentView.swift
//  eintodo
//
//  Created by anh :) on 17.06.22.
//

/**Sidebar and Toolbar**/

import SwiftUI
import RealmSwift

struct ContentView: View {
    @State var username: String = ""
    
    var body: some View {
        if username == ""{
            LoginView(username: $username)
        } else {
            if let user = realmApp.currentUser{
                HomeView()
                    .environment(\.realmConfiguration, user.configuration(partitionValue: user.id))
            }
        }
    }
}

//Reset the Realm storage
struct ResetRealm: View{
    var body: some View{
        Button("reset realm"){
            reset()
            print("realm resetted")
        }
    }
    func reset(){
        try? FileManager.default.removeItem(at: user.configuration(partitionValue: user.id).fileURL!)
    }
}

