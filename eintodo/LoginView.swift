//
//  LoginView.swift
//  eintodo
//
//  Created by anh :) on 21.06.22.
//

import SwiftUI

struct LoginView: View {
    @Binding var username: String
    var body: some View {
        VStack{
            ProgressView()
                .onAppear(perform: login)
        }
        .padding()
    }
    
    func login(){
        Task {
            do {
                let user = try await realmApp.login(credentials: .anonymous)
                username = user.id
            } catch{
                print("Failed to log in: \(error.localizedDescription)")
            }
        }
    }
}
