//
//  CalendarView.swift
//  eintodo
//
//  Created by anh :) on 17.06.22.
//

/**The CalendarView shall combine ToDos, CalendarEvents and Routines together. For Now it displays To-Dos in a Calendar view**/

import SwiftUI
import RealmSwift

struct CalendarView: View{
    @ObservedResults(ToDo.self) var todos
    @EnvironmentObject var global: Global
    @State var selectedMonth: Int = CalendarDate().getCurrentMonth()

    private var grid: [GridItem] = Array(repeating: .init(.flexible(minimum: 30, maximum: 40)), count: 7)
    private var weekdays: [String] = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
    
    @State var filter: NSPredicate = NSPredicate()
    
    var body: some View{
        NavigationView{
            //CalendarView
            VStack{
                HStack{
                    Text(CalendarDate().getYear(input: selectedMonth))
                        .fontWeight(.light)
                        .font(.title)
                    Text(CalendarDate().getMonth(input: selectedMonth)).bold()
                        .font(.title)
                    Spacer()
                    MonthButton(systemName: "chevron.left", month: $selectedMonth){
                        selectedMonth-=1
                    }
                    MonthButton(systemName: "chevron.right", month: $selectedMonth){
                        selectedMonth+=1
                    }
                }
                LazyVGrid(columns: grid){
                    ForEach(weekdays, id: \.self){ weekday in
                        Text(weekday).bold()
                    }
                    ForEach(CalendarDate().getDaysOfMonth(selectedMonth: selectedMonth), id: \.self){ dayValue in
                        if dayValue.day == -1{
                            Text("")
                        } else {
                            Button(action: {
                                global.selectedDate = dayValue.date
                            }, label: {
                                //If selected date
                                if(Date().isSameDay(date1: dayValue.date, date2: global.selectedDate)){
                                    ZStack{
                                        Circle().fill(.blue)
                                            .frame(width: 30, height: 30)
                                        Text("\(dayValue.day)")
                                            .fontWeight(.regular)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                } else {
                                    ZStack{
                                        Circle().fill(dayValue.hasItems ? .blue : .clear)
                                            .opacity(0.1)
                                            .frame(width: 30, height: 30)
                                        Text("\(dayValue.day)")
                                            .fontWeight(Date().isSameDay(date1: Date(), date2: dayValue.date) ? .regular : .light)
                                             .font(.headline)
                                            .foregroundColor(Date().isSameDay(date1: Date(), date2: dayValue.date) ? .blue : .primary) //If today -> blue, else -> default
                                    }
                                }
                            }).buttonStyle(.plain)
                        }
                    }
                }
                //Keyboard-Shortcut
                Group{
                    Button("Left arrow"){
                        let comp = Calendar.current.dateComponents([.day], from: global.selectedDate)
                        if comp.day! - 1 < 1{
                            selectedMonth -= 1
                        }
                        global.selectedDate = global.selectedDate.addingTimeInterval(-60*60*24)
                    }.keyboardShortcut(KeyEquivalent.leftArrow, modifiers: [])
                    
                    Button("Up arrow"){
                        let comp = Calendar.current.dateComponents([.day], from: global.selectedDate)
                        if comp.day! - 7 < 1{
                            selectedMonth -= 1
                        }
                        global.selectedDate = global.selectedDate.addingTimeInterval(-60*60*24*7)
                    }.keyboardShortcut(KeyEquivalent.upArrow, modifiers: [])
                        
                    Button("Right arrow"){
                        let comp = Calendar.current.dateComponents([.day], from: global.selectedDate)
                        let amountOfDaysInMonth = Calendar.current.range(of: .day, in: .month, for: global.selectedDate)!.endIndex-1
                        if comp.day! + 1 > amountOfDaysInMonth{
                            selectedMonth += 1
                        }
                        global.selectedDate = global.selectedDate.addingTimeInterval(60*60*24)
                    }.keyboardShortcut(KeyEquivalent.rightArrow, modifiers: [])
                    
                    Button("Down arrow"){
                        let comp = Calendar.current.dateComponents([.day], from: global.selectedDate)
                        let amountOfDaysInMonth = Calendar.current.range(of: .day, in: .month, for: global.selectedDate)!.endIndex-1
                        if comp.day! + 7 > amountOfDaysInMonth{
                            selectedMonth += 1
                        }
                        global.selectedDate = global.selectedDate.addingTimeInterval(60*60*24*7)
                    }.keyboardShortcut(KeyEquivalent.downArrow, modifiers: [])
                }.opacity(0)
                
                Spacer()
                HStack{
                    Spacer()
                    Button("Heute"){
                        global.selectedDate = Date()
                        selectedMonth = CalendarDate().getCurrentMonth()
                    }.buttonStyle(.plain)
                        .foregroundColor(.blue)
                }
            }
            .frame(minWidth: 300)
            .padding()
            
            ToDoListView(type: .date)
        }
    }
}


class CalendarDate{
    struct DateValue: Hashable{
        let id = UUID().uuidString
        var day: Int
        var date: Date
        var hasItems: Bool
    }
    
    let calendar = Calendar.current
    
    //Get current year as an int value
    func getCurrentYear(date: Date = Date())->Int{
        let components = calendar.dateComponents([.year], from: date)
        return components.year!
    }
        
    //Get current month as an int value
    func getCurrentMonth(date: Date = Date())->Int{
        let components = calendar.dateComponents([.month], from: date)
        return components.month!
    }
    
    //Get selected year with an input of a selected month
    func getYear(input: Int?)->String{
        let date = getDateFromComponents(month: input!+1)
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY"
        return formatter.string(from: date)
    }
    
    //Get selected month
    func getMonth(input: Int?)->String{
        let date = getDateFromComponents(month: input)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        formatter.locale = Locale(identifier: "de")
        return formatter.string(from: date)
    }

    //Get all days of each month
    func getDaysOfMonth(selectedMonth: Int?)->[DateValue]{
        var month: [DateValue] = []
        let date = getDateFromComponents(month: selectedMonth)
        let firstWeekday = calendar.component(.weekday, from: startOfMonth(date: date))+7
        for _ in 0...firstWeekday-3{
            month.append(DateValue(day: -1, date: Date.isNotActive, hasItems: false))
        }
        let range = calendar.range(of: .day, in: .month, for: date)!
        for i in range{
            let dateStored = getDateFromComponents(month: selectedMonth, day: i)
            let isEmpty = realmEnv.objects(ToDo.self).filter(ToDoFilter().withSelectedDate(d: dateStored)).isEmpty
            let dateValue = DateValue(day: i, date: dateStored, hasItems: !isEmpty)
            month.append(dateValue)
        }
        return month
    }
    
    //Get the date with selectedMonth
    func getDateFromComponents(year: Int? = Calendar.current.dateComponents([.year], from: Date()).year, month: Int?, day: Int? = 1)->Date{
        let dateComponents = DateComponents(year: year, month: month, day: day)
        return calendar.date(from: dateComponents) ?? Date()
    }
    
    //Get the start of the month
    func startOfMonth(date: Date) -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: date)))!
    }
}

//Subviews
struct MonthButton: View{
    let systemName: String
    @Binding var month: Int
    let action: () -> ()
    var body: some View{
            Button(action: {
                action()
            }, label: {
                ZStack{
                    Circle().fill(.blue).opacity(0.1)
                    Image(systemName: systemName)
                        .foregroundColor(.blue)
                }.frame(width: 25, height: 25)
            }).buttonStyle(.plain)
    }
}
