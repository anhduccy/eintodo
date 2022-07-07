//
//  CalendarView.swift
//  eintodo
//
//  Created by anh :) on 17.06.22.
//

/**The CalendarView shall combine ToDos, CalendarEvents and Routines together. For Now it displays To-Dos in a Calendar view**/

import SwiftUI
import RealmSwift
import UniformTypeIdentifiers

struct CalendarView: View{
    @Environment(\.colorScheme) var appearance
    @ObservedResults(ToDo.self) var todos
    @EnvironmentObject var global: Global
    @State var selectedMonth: Int = CalendarDate.getCurrentMonth()

    private var grid: [GridItem] = Array(repeating: .init(.flexible(minimum: 30, maximum: 40)), count: 7)
    private var weekdays: [String] = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
    
    @State var filter: NSPredicate = NSPredicate()
    
    var body: some View{
        NavigationView{
            //CalendarView
            VStack{
                HStack{
                    Text(CalendarDate.getYear(input: selectedMonth))
                        .fontWeight(.light)
                        .font(.title)
                    Text(CalendarDate.getMonth(input: selectedMonth)).bold()
                        .font(.title)
                    Spacer()
                    
                    Button(action: {
                        global.selectedDate = Date()
                        selectedMonth = CalendarDate.getCurrentMonth()
                    }, label: {
                        ZStack{
                            Circle().fill(.blue).opacity(0.1)
                            Image(systemName: "\(CalendarDate.getCurrentDay()).circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15)
                                .foregroundColor(.blue)
                        }.frame(width: 26, height: 26)
                    }).buttonStyle(.plain)
                    
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
                    ForEach(CalendarDate.getDaysOfMonth(selectedMonth: selectedMonth), id: \.self){ dayValue in
                        if dayValue.day == -1{
                            Text("")
                        } else {
                            Button(action: {
                                global.selectedDate = dayValue.date
                            }, label: {
                                //If selected date
                                if(Date.isSameDay(date1: dayValue.date, date2: global.selectedDate)){
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
                                        Circle().fill(dayValue.color)
                                            .opacity(0.15)
                                            .frame(width: 30, height: 30)
                                        Text("\(dayValue.day)")
                                            .fontWeight(Date.isSameDay(date1: Date(), date2: dayValue.date) ? .regular : .light)
                                             .font(.headline)
                                            .foregroundColor(Date.isSameDay(date1: Date(), date2: dayValue.date) ? .blue : .primary) //If today -> blue, else -> default
                                    }
                                }
                            }).buttonStyle(.plain)
                                .onDrop(of: [UTType.text], delegate: ToDoCalendarViewDropDelegate(global: global, date: dayValue.date))
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
            }
            .frame(minWidth: 300, idealWidth: 300, maxWidth: 300)
            .padding()
            
            ToDoListView(type: .date)
        }
        .background(appearance == .dark ? ColorPalette.backgroundDarkmode : ColorPalette.backgroundLightmode)
    }
}


class CalendarDate{
    ///Model of each Calendar Button in CalendarView
    struct DateValue: Hashable{
        let id = UUID().uuidString
        var day: Int
        var date: Date
        var color: Color
    }
    
    static let calendar = Calendar.current
    
    static func getCurrentDay(date: Date = Date())->Int{
        let components = calendar.dateComponents([.day], from: date)
        return components.day!
    }
    
    ///Return the current year as an int value
    static func getCurrentYear(date: Date = Date())->Int{
        let components = calendar.dateComponents([.year], from: date)
        return components.year!
    }
        
    ///Return the current month as an int value
    static func getCurrentMonth(date: Date = Date())->Int{
        let components = calendar.dateComponents([.month], from: date)
        return components.month!
    }
    
    ///Return the year depending on a selected month (Int) as an input
    static func getYear(input: Int?)->String{
        let date = getDateFromComponents(month: input!+1)
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY"
        return formatter.string(from: date)
    }
    
    ///Return the month depending on a selected month (Int) as an input
    static func getMonth(input: Int?)->String{
        let date = getDateFromComponents(month: input)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        formatter.locale = Locale(identifier: "de")
        return formatter.string(from: date)
    }

    ///Get all days of a selected month (Int) as an input
    static func getDaysOfMonth(selectedMonth: Int?)->[DateValue]{
        var month: [DateValue] = []
        let date = getDateFromComponents(month: selectedMonth)
        let firstWeekday = calendar.component(.weekday, from: startOfMonth(date: date))+7
        for _ in 0...firstWeekday-3{
            month.append(DateValue(day: -1, date: Date.isNotActive, color: .clear))
        }
        let range = calendar.range(of: .day, in: .month, for: date)!
        for i in range{
            let dateStored = getDateFromComponents(month: selectedMonth, day: i)
            var colorDateInPast: Color = dateStored < Calendar.current.startOfDay(for: Date()) ? .red : .blue
            if realmEnv.objects(ToDo.self).filter(ToDoFilter.withSelectedDate(d: dateStored)).isEmpty{
                colorDateInPast = .clear
            }
            let dateValue = DateValue(day: i, date: dateStored, color: colorDateInPast)
            month.append(dateValue)
        }
        return month
    }
    
    ///Combine DateComponents [.year] and [.month] to a valid date
    static func getDateFromComponents(year: Int? = Calendar.current.dateComponents([.year], from: Date()).year, month: Int?, day: Int? = 1)->Date{
        let dateComponents = DateComponents(year: year, month: month, day: day)
        return calendar.date(from: dateComponents) ?? Date()
    }
    
    ///Get the start of the month depending on an input date
    static func startOfMonth(date: Date) -> Date {
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
