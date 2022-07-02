//
//  LoginView.swift
//  eintodo
//
//  Created by anh :) on 21.06.22.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.colorScheme) var appearance
    @EnvironmentObject var global: Global
    
    @State var email: String = ""
    @State var password: String = ""
    
    @State var showErrorMessage: String = ""
    var body: some View {
        HStack{
            Rectangle().foregroundColor(.white)
            
            VStack{
                Spacer()
                TextField("E-Mail", text: $email)
                    .textFieldStyle(.plain)
                    .padding(7.5)
                    .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(email == "" ? .gray : .blue, lineWidth: 1)
                                .opacity(0.5)
                        )
                SecureField("Passwort", text: $password)
                    .textFieldStyle(.plain)
                    .padding(7.5)
                    .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(password == "" ? .gray : .blue, lineWidth: 1)
                                .opacity(0.5)
                        )
                
                HStack{
                    Spacer()
                    Button(action: {
                        register()
                    }, label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 5)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .blue, radius: 2)
                            
                            Text("Registrieren").foregroundColor(.blue)
                        }.frame(width: 120, height: 32.5)
                    }).buttonStyle(.plain)
                    
                    Button(action: {
                        login()
                    }, label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 5)
                                .fill(.blue)
                                .shadow(color: appearance == .dark ? .gray : .white, radius: 1)
                            
                            Text("Anmelden").foregroundColor(.white)
                        }.frame(width: 120, height: 32.5)
                    }).buttonStyle(.plain)
                }
                Spacer()
                ZStack{
                    RoundedRectangle(cornerRadius: 5).fill(showErrorMessage != "" ? .blue : .clear).opacity(0.2)
                    if showErrorMessage != "" {
                        HStack{
                            Image(systemName: "info.circle").foregroundColor(.blue)
                            Text(showErrorMessage).font(.caption).foregroundColor(.blue)
                            Spacer()
                        }.padding(.leading)
                    }
                }.frame(height: 32.5)
            }
            .padding()
        }
    }
    private func login(){
        Task {
            do {
                let user = try await realmApp.login(credentials: .emailPassword(email: email, password: password))
                global.username = user.id
            } catch{
                showErrorMessage = "\(error.localizedDescription)".capitalized(with: Locale(identifier: "en"))
            }
        }
    }
    private func register(){
        Task {
            do {
                try await realmApp.emailPasswordAuth.registerUser(email: email, password: password)
                login()
            } catch{
                showErrorMessage = "\(error.localizedDescription)".capitalized(with: Locale(identifier: "en"))
            }
        }
    }
}
