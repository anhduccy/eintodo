//
//  NotificationCenter.swift
//  eintodo
//
//  Created by anh :) on 30.06.22.
//

import Foundation
import UserNotifications
import RealmSwift

class NotificationCenter{
    static func askForUserNotificationPermission(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]){ success, error in
            if success {
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    static func updateToDo(title: String, id: String, date: Date){
        if date != Date.isNotActive{
            deleteToDo(id: id)
            //Add UserNotification
            let content = UNMutableNotificationContent()
            content.title = title
            content.subtitle = "Fällig am \(Date.format(displayType: "date", date: date))"
            content.sound = UNNotificationSound.default
                        
            if(Date.getInterval(from: date) > 0){
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(Date.getInterval(from: date)), repeats: false)
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
                print("The notification is set for \(date) with title '\(title)', subtitle: '\(content.subtitle)') and id: ‘\(id)'")
            }
        }
    }
    static func deleteToDo(id: String){
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [id])
        print("The notification with id \(id) is removed")
    }
}

extension Date{
    static func getInterval(from date: Date) -> Int {
        let interval = Calendar.current.dateComponents([.second], from: Date(), to: date).second!
        return interval
    }
}
