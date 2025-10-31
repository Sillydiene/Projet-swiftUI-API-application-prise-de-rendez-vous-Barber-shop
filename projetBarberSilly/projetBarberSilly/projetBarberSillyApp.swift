//
//  projetBarberSillyApp.swift
//  projetBarberSilly
//
//  Created by MacBook Pro Silly on 2025-10-22.
//

// RendezVousApp.swift
import SwiftUI

@main
struct RendezVousApp: App {
    @StateObject var auth = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if auth.currentUser == nil {
                    LoginView()
                } else {
                    AppointmentsListView()
                }
            }
            .environmentObject(auth)
        }
    }
}
