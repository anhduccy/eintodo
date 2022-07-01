//
//  Global.swift
//  eintodo
//
//  Created by anh :) on 18.06.22.
//

import Foundation
import RealmSwift

///Global User Model for user navigation
class Global: ObservableObject{
    init(){
        selectedDate = Date()        
        showCompletedToDos = false
        selectedList = ToDoList()
        selectedView = 0
    }
    
    @Published var selectedDate: Date
    @Published var selectedList: ToDoList
    @Published var selectedView: Int?
    @Published var showCompletedToDos: Bool
}

class SymbolCatalog{
    static let s: [String] = ["list.bullet", "bookmark.fill", "mappin", "gift.fill", "graduationcap.fill", "doc.fill", "book.fill", "banknote", "creditcard.fill", "figure.walk", "fork.knife", "house.fill", "tv.fill", "music.note", "pc", "gamecontroller.fill", "headphones", "beats.headphones", "leaf.fill", "person.fill", "person.2.fill", "person.3.fill", "pawprint.fill", "cart.fill", "bag.fill", "shippingbox.fill", "tram.fill", "airplane", "car.fill", "sun.max.fill", "moon.fill", "drop.fill", "snowflake", "flame.fill", "screwdriver.fill", "scissors", "curlybraces", "chevron.left.forwardslash.chevron.right", "lightbulb.fill", "bubble.left.fill", "staroflife.fill", "square.fill", "circle.fill", "triangle.fill", "heart.fill", "star.fill"]
}


extension Date{
    ///The default date when a date is not active
    static var isNotActive = Date(timeIntervalSince1970: 0)
    
    ///**String formatter for different types:** *date*: Display only the date, *dateAndTime*: Display the date and the time (default), *time*: Display only the time
    static func format(displayType: String = "dateAndTime",date: Date)->String{
        let formatter = DateFormatter()
        if displayType == "date"{
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
        } else if displayType == "time"{
            formatter.dateStyle = .none
            formatter.timeStyle = .short
        } else {
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
        }
        formatter.locale = Locale(identifier: "de")
        return formatter.string(from: date)
    }
    
    ///Compare two dates, if both have the same date, return true, else false
    static func isSameDay(date1: Date, date2: Date)->Bool{
        let cal = Calendar.current
        let one = cal.startOfDay(for: date1)
        let two = cal.startOfDay(for: date2)
        return one == two ? true : false
    }
    
    ///Combine the input date with the UserDefault stored attribute deadlineTime to a new valid date
    static func createDeadlineTime(inputDate: Date)->Date{
        let comp = Calendar.current.dateComponents([.day, .month, .year], from: inputDate)
        
        let dateStr = "\(comp.year!)-\(comp.month!)-\(comp.day!)"
        let timeStr = UserDefaults.standard.string(forKey: "deadlineTime")
        let df = DateFormatter()
        df.dateFormat = "y-M-d HH:mm"
        let date = df.date(from: dateStr + " " + timeStr!)
        return date ?? inputDate
    }
}

class ToDoFilter{
    ///Show all to-dos depending on a given list
    static func withSelectedListAll(l: ToDoList)->NSPredicate{
        let predicate = NSPredicate(format: "_id == %@", l._id)
        return predicate
    }
    ///Show the to-dos which is not completed yet
    static func showNotCompleted()->NSPredicate{
        let predicate = NSPredicate(format: "completed == false")
        return predicate
    }
    ///Show all to-dos depending on a given date
    static func withSelectedDateAll(d: Date)->NSPredicate{
        let cal = Calendar.current
        let dateFrom = cal.startOfDay(for: d)
        let dateTo = cal.date(byAdding: .second, value: 60*60*24, to: dateFrom)
        let predicate = NSPredicate(format: "deadline >= %@ && deadline <= %@", dateFrom as CVarArg, dateTo! as CVarArg)
        return predicate
    }
    ///Show all to-dos which has been not done yet, depending on a given date
    static func withSelectedDate(d: Date)->NSPredicate{
        let cal = Calendar.current
        let dateFrom = cal.startOfDay(for: d)
        let dateTo = cal.date(byAdding: .second, value: 60*60*24, to: dateFrom)
        let predicate = NSPredicate(format: "deadline >= %@ && deadline <= %@ && completed == false", dateFrom as CVarArg, dateTo! as CVarArg)
        return predicate
    }
}

//Enumerations
enum EditViewType{
    case add, edit
}
