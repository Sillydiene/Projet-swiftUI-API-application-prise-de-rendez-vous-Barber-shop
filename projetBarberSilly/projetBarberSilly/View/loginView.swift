//
//  loginView.swift
//  projetBarberSilly
//
//  Created by MacBook Pro Silly on 2025-10-22.
//
//silly@gmail.com
//silly


// LoginView.swift


import SwiftUI

//Vue principale pour la connexion des utilisateurs
struct LoginView: View {
    
    //ViewModel partagé pour la gestion de l’authentification
    @EnvironmentObject var auth: AuthViewModel
    
    //États locaux pour stocker les valeurs saisies et la navigation
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false      // Affiche la page d’inscription
    @State private var isLoggedIn = false        // Déclenche la navigation vers la page principale

    var body: some View {
        NavigationStack {
            ZStack {
                //Image de fond plein écran
                Image("barber_bg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                //Superposition sombre pour améliorer la lisibilité du texte
                Color.black.opacity(0.6)
                    .ignoresSafeArea()

                //Contenu principal du formulaire
                VStack(spacing: 16) {
                    Spacer(minLength: 100) // Ajoute de l’espace en haut

                    //Titre principal
                    Text("Connexion")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)

                    // Champs de saisie pour email et mot de passe
                    VStack(spacing: 12) {
                        
                        // Champ pour l'adresse e-mail
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.25))
                            )

                        //Champ pour le mot de passe
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

                    //Affiche un message d'erreur si la connexion échoue
                    if let err = auth.error {
                        Text(err)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    //Bouton de connexion
                    Button {
                        // Appel de la méthode login du ViewModel
                        auth.login(email: email, password: password)
                    } label: {
                        if auth.isLoading {
                            // Si en cours de chargement → affiche un indicateur
                            ProgressView()
                                .tint(.white)
                        } else {
                            // Sinon → bouton normal
                            Text("Se connecter")
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

                    //Lien pour ouvrir la page d’inscription
                    Button("Créer un compte") {
                        showRegister = true
                    }
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.top, 8)

                    Spacer() // Espace avant le bas de l’écran
                }
                .padding(.bottom, 40)
            }

            //Détecte un changement d’état de l’utilisateur
            .onChange(of: auth.currentUser) { oldValue, newValue in
                // Si un utilisateur est connecté, on déclenche la navigation
                if newValue != nil {
                    isLoggedIn = true
                }
            }

            //Ouvre la vue d’inscription dans une feuille modale
            .sheet(isPresented: $showRegister) {
                RegisterView()
                    .environmentObject(auth)
            }

            //Navigation vers la liste des rendez-vous après connexion
            .navigationDestination(isPresented: $isLoggedIn) {
                AppointmentsListView()
                    .environmentObject(auth)
            }
        }
    }
}

//Aperçu pour Xcode Canvas
#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
