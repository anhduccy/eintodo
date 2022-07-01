//
//  ToDoFilter.swift
//  eintodo
//
//  Created by anh :) on 01.07.22.
//

import Foundation

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
