//
//  ViewLibrary.swift
//  eintodo
//
//  Created by anh :) on 17.06.22.
//

/**ViewLibrary - A place where small UI-Snippets are used in a lot of files*/

import SwiftUI

struct SystemDatePicker: View{
    init(displayType: String = "dateAndTime", date: Binding<Date>, title: String, systemName: String, size: CGFloat, color: Color = .blue){
        self.type = displayType
        _date = date
        self.title = title
        self.systemName = systemName
        self.size = size
        self.color = color
        if(date.wrappedValue != Date.isNotActive){
            _bool = State(initialValue: true)
        } else {
            _bool = State(initialValue: false)
        }
    }
    @EnvironmentObject var global: Global
    let type: String
    @Binding var date: Date
    let title: String
    let systemName: String
    let size: CGFloat
    let color: Color
    
    @State var bool: Bool
    var body: some View{
        HStack(alignment: .center){
            Button(action: {
                withAnimation{
                    if date != Date.isNotActive{
                        date = Date(timeIntervalSince1970: 0)
                    } else {
                        date = global.selectedDate
                    }
                }
            }, label: {
                SystemIcon(isActive: bool, systemName: systemName, size: size, color: color)
                    .onChange(of: date){ _ in
                        if(date != Date.isNotActive){
                            bool = true
                        } else {
                            bool = false
                        }
                    }
            }).buttonStyle(.plain)
            Text(title)
            Spacer()
            if date != Date.isNotActive{
                DatePicker("", selection: $date, displayedComponents: type == "dateAndTime" ? [.date, .hourAndMinute] : [.date])
                    .datePickerStyle(.stepperField)
                    .frame(width: 200)
            } else {
                Text("Nicht aktiviert")
                    .foregroundColor(.gray)
                    .opacity(0.5)
            }
        }
    }
}

struct SystemIcon: View{
    init(isActive: Bool = true, systemName: String, size: CGFloat, color: Color = .blue){
        self.isActive = isActive
        self.systemName = systemName
        self.size = size
        self.color = color
    }
    var isActive: Bool
    let systemName: String
    let size: CGFloat
    let color: Color
    var body: some View{
        ZStack{
            Circle().fill(color)
                .opacity(isActive ? 1 : 0.1)
                .frame(width: size-1, height: size-1)
            Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .frame(width: size/2, height: size/2)
                .foregroundColor(isActive ? .white : color)
                .opacity(isActive ? 1 : 0.5)
        }
    }
}

struct LeftText: View{
    init(text: String, font: Font = .body, fontWeight: Font.Weight = .regular){
        self.text = text
        self.font = font
        self.fontWeight = fontWeight
    }
    let text: String
    let font: Font
    let fontWeight: Font.Weight
    var body: some View{
        HStack{
            Text(text)
                .font(font)
                .fontWeight(fontWeight)
            Spacer()
        }
    }
}
