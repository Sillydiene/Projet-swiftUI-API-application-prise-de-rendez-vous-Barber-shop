//
//  RegisterView.swift
//  projetBarberSilly
//
//  Created by MacBook Pro Silly on 2025-10-22.
//

// RegisterView.swift
import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var auth: AuthViewModel
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    
    @State private var showSuccess = false
    @State private var showError = false
    @State private var goToLogin = false   //redirige vers LoginView

    var body: some View {
        NavigationStack {
            ZStack {
                //IMAGE DE FOND
                Image("barber_bggg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                //VOILE sombre pour lisibilité du texte
                Color.black.opacity(0.6)
                    .ignoresSafeArea()

                //CONTENU DU FORMULAIRE
                ScrollView {
                    VStack(spacing: 16) {
                        Spacer(minLength: 100)

                        Text("Inscription")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)

                        //Champs de saisie
                        VStack(spacing: 12) {
                            TextField("Nom", text: $name)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.25))
                                )

                            TextField("Email", text: $email)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.25))
                                )

                            SecureField("Mot de passe", text: $password)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.25))
                                )
                        }
                        .padding(.horizontal, 24)

                        //Erreur éventuelle
                        if let err = auth.error {
                            Text(err)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }

                        //Bouton de création
                        Button {
                            Task {
                                await auth.register(name: name, email: email, password: password)

                                if auth.currentUser != nil {
                                    showSuccess = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        goToLogin = true
                                    }
                                } else {
                                    showError = true
                                }
                            }
                        } label: {
                            if auth.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Créer le compte")
                                    .bold()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(12)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)

                        //Lien retour connexion
                        Button("Déjà un compte ? Se connecter") {
                            goToLogin = true
                        }
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 8)

                        Spacer()
                    }
                    .padding(.bottom, 40)
                }

                //Bouton “Fermer” flottant
                VStack {
                    HStack {
                        Button("Fermer") {
                            goToLogin = true
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.15), in: Capsule())
                        .padding(.leading, 16)
                        .padding(.top, 20)
                        Spacer()
                    }
                    Spacer()
                }
            }
            //Alertes
            .alert("Compte créé avec succès 🎉", isPresented: $showSuccess) {
                Button("OK") { goToLogin = true }
            }
            .alert("Erreur lors de l’inscription", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                if let err = auth.error {
                    Text(err)
                }
            }
            //Redirection
            .navigationDestination(isPresented: $goToLogin) {
                LoginView()
                    .environmentObject(auth)
            }
        }
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthViewModel())
}
