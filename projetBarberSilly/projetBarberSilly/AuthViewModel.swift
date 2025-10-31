//
//  AuthViewModel.swift
//  projetBarberSilly
//
//  Created by MacBook Pro Silly on 2025-10-22.
//

// AuthViewModel.swift
import Foundation
import Combine
import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var currentUser: User? = nil
    @Published var isLoading = false
    @Published var error: String? = nil

    func login(email: String, password: String) {
            isLoading = true
            error = nil
            
        APIClient.shared.login(email: email, password: password) { result in
                    DispatchQueue.main.async {
                        self.isLoading = false
                        switch result {
                        case .success(let json):
                            guard
                                let id = json["id"] as? String,
                                let name = json["name"] as? String,
                                let jsonEmail = json["email"] as? String
                            else {
                                self.currentUser = nil
                                self.error = "Réponse invalide du serveur."
                                return
                            }

                            //On construit l'utilisateur SANS exiger 'password' du serveur
                            self.currentUser = User(id: id, name: name, email: jsonEmail)

                        case .failure(let errorDict):
                            self.currentUser = nil
                            self.error = errorDict["error"] as? String ?? "Échec de connexion."
                        }
                    }
                }
            }

    func register(name: String, email: String, password: String) async {
        isLoading = true; error = nil
        do {
            let u = try await APIClient.shared.register(name: name, email: email, password: password)
            currentUser = u
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func logout() {
        currentUser = nil
    }
}
#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
