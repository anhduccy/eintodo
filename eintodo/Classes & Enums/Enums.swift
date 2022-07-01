//
//  Enums.swift
//  eintodo
//
//  Created by anh :) on 01.07.22.
//

import Foundation

///There are different settings of an EditView: **Add** where the default attributes are set, **Edit** where the specific attributes of an object are set
enum EditViewType{
    case add, edit
}

///There are different types of lists in ToDoListView: **All** to show all to-dos, **Date** to show to-dos from a specific date, **List** to show to-dos from a specific user-created list
enum ToDoListType{
    case all, date, list
}
