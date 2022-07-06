//
//  Migrator.swift
//  eintodo
//
//  Created by anh :) on 20.06.22.
//

import Foundation
import RealmSwift

class Migrator{
    
    init(){
        updateSchema()
    }
    
    func updateSchema(){
        let version = 4
        let newConfig = Realm.Configuration(schemaVersion: UInt64(version)){ migration, oldSchemaVersion in
            if oldSchemaVersion < version{
                migration.enumerateObjects(ofType: SubToDo.className()){ oldObj, newObj in
                }
                migration.enumerateObjects(ofType: ToDo.className()){ oldObj, newObj in
                }
                migration.enumerateObjects(ofType: ToDoList.className()){ oldObj, newObj in
                }
            }
        }
        Realm.Configuration.defaultConfiguration = newConfig
        let _ = realmEnv
    }
}
