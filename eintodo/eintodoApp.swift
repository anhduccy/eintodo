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
let realmApp = RealmSwift.App(id: getKey())
var realmEnv = try! Realm(configuration: .defaultConfiguration)

func getKey() -> String {
	let apiKey = Bundle.main.object(forInfoDictionaryKey: "Realm_Key") as? String
	guard let key = apiKey, !key.isEmpty else {
		print("could not load key!")
		return ""
	}
	return key
}

@main
struct eintodoApp: SwiftUI.App {
    
    let migrator = Migrator()
    
    let modus = 0 //To reset the db more easily
    var body: some Scene {
        WindowGroup {
            if modus == 0{
                ContentView()
                    .onAppear{
                        if let user = realmApp.currentUser{
                            print(user.configuration(partitionValue: user.id).fileURL?.path ?? "Could not find realm database in files")
                        }
                        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatifaiable")
                    }
                    .environmentObject(Global())
                    .navigationTitle("eintodo")
            } else {
                ResetRealm()
            }
        }
    }
}


