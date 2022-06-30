//
//  eintodoApp.swift
//  eintodo
//
//  Created by anh :) on 18.06.22.
//

import Foundation
import SwiftUI
import RealmSwift
import Realm


//Realm Setup
let realmApp = RealmSwift.App(id: "***REMOVED***")
let user = realmApp.currentUser! //<- IF NO LOGIN FAIL
let realmEnv = try! Realm(configuration: user.configuration(partitionValue: user.id))

@main
struct eintodoApp: SwiftUI.App {
    
    let migrator = Migrator()
    
    let modus = 0 //To reset the db more easily
    var body: some Scene {
        WindowGroup {
            if modus == 0{
                ContentView()
                    .onAppear{
                        print(user.configuration(partitionValue: user.id).fileURL?.path ?? "Could not find realm database in files")
                        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatifaiable")
                    }
                    .environmentObject(Global())
                    .navigationTitle("eintodo")
                    .frame(minWidth: 900)
            } else {
                ResetRealm()
            }
        }
        
        Settings{
            SettingsView()
        }
    }
}


