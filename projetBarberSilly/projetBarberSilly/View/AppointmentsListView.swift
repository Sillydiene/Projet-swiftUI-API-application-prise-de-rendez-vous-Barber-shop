//
//  AppointmentsListView.swift
//  projetBarberSilly
//
//  Created by MacBook Pro Silly on 2025-10-22.
//

// AppointmentsListView.swift
import SwiftUI

// Vue principale affichant la liste des rendez-vous d’un utilisateur connecté
struct AppointmentsListView: View {
    
    // Objet d’environnement gérant l’authentification
    @EnvironmentObject var auth: AuthViewModel
    
    // ViewModel local pour charger, ajouter, modifier et supprimer les rendez-vous
    @StateObject var vm = AppointmentsViewModel()
    
    // États pour gérer l’affichage de l’éditeur et le rendez-vous à modifier
    @State private var showEditor = false
    @State private var editing: Appointment? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                // IMAGE DE FOND pleine page
                Image("barber")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                // VOILE semi-transparent pour rendre le texte lisible
                Color.black.opacity(0.55)
                    .ignoresSafeArea()

                // CONTENU PRINCIPAL
                Group {
                    //Si l’utilisateur est connecté
                    if let user = auth.currentUser {
                        
                        //Liste des rendez-vous
                        List {
                            ForEach(vm.items) { appt in
                                
                                // 🖊️ Chaque rendez-vous est un bouton pour ouvrir l’éditeur
                                Button {
                                    editing = appt        // Sélectionne le rendez-vous à modifier
                                    showEditor = true     // Ouvre la feuille d’édition
                                } label: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        //Titre du rendez-vous
                                        Text(appt.title)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        
                                        //Notes (si présentes)
                                        if let notes = appt.notes, !notes.isEmpty {
                                            Text(notes)
                                                .font(.subheadline)
                                                .foregroundColor(.white.opacity(0.85))
                                        }
                                        
                                        //Date et heure formatées
                                        Text(appt.date.formatted(date: .abbreviated, time: .shortened))
                                            .font(.footnote)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    //Style visuel des cellules
                                    .padding(10)
                                    .background(Color.black.opacity(0.35))
                                    .cornerRadius(10)
                                }
                                .listRowBackground(Color.clear) //fond transparent pour chaque ligne
                                
                                //Swipe pour suppression
                                .swipeActions {
                                    Button(role: .destructive) {
                                        // Suppression asynchrone d’un rendez-vous
                                        Task { await vm.deleteOne(appt) }
                                    } label: {
                                        Label("Supprimer", systemImage: "trash")
                                    }
                                }
                            }
                            //Suppression multiple avec .onDelete
                            .onDelete { idx in
                                Task { await vm.delete(at: idx) }
                            }
                        }
                        //Réglages d’apparence de la liste
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        
                        //Superposition de feedback (chargement, erreurs, vide)
                        .overlay {
                            //Indicateur de chargement
                            if vm.isLoading {
                                ProgressView("Chargement…")
                                    .tint(.white)
                            }
                            //Affichage des erreurs
                            if let err = vm.error {
                                Text(err)
                                    .foregroundColor(.red)
                            }
                            //Message si aucun rendez-vous
                            if !vm.isLoading && vm.items.isEmpty {
                                ContentUnavailableView(
                                    "Aucun rendez-vous",
                                    systemImage: "calendar.badge.exclamationmark",
                                    description: Text("Ajoutez votre premier rendez-vous.")
                                )
                                .foregroundColor(.white)
                            }
                        }
                        //Chargement initial des rendez-vous
                        .task { await vm.load(userId: user.id) }
                        
                    } else {
                        //Si aucun utilisateur n’est connecté
                        ContentUnavailableView(
                            "Non connecté",
                            systemImage: "person.fill.questionmark",
                            description: Text("Veuillez vous connecter.")
                        )
                        .foregroundColor(.white)
                    }
                }
            }

            //BARRE DE NAVIGATION
            .navigationTitle("Rendez-vous")
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black.opacity(0.8), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)

            //Boutons dans la barre
            .toolbar {
                //Bouton de déconnexion (haut gauche)
                ToolbarItem(placement: .topBarLeading) {
                    Button("Déconnexion") {
                        auth.logout() // Appelle la méthode du ViewModel
                    }
                    .foregroundColor(.white)
                }

                //Bouton d’ajout (haut droite)
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        editing = nil       // Pas de rendez-vous sélectionné → création
                        showEditor = true   // Ouvre l’éditeur
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                    }
                }
            }

            //FEUILLE MODALE : Éditeur de rendez-vous
            .sheet(isPresented: $showEditor) {
                if let user = auth.currentUser {
                    AppointmentEditorView(user: user, appointment: editing) { result in
                        // Callback déclenché à la fermeture de l’éditeur
                        Task {
                            switch result {
                            //Création d’un nouveau rendez-vous
                            case .created(let a):
                                await vm.add(userId: user.id, title: a.title, notes: a.notes, date: a.date)
                            //Mise à jour d’un rendez-vous existant
                            case .updated(let a):
                                await vm.update(a)
                            //Annulation
                            case .cancelled:
                                break
                            }
                        }
                    }
                }
            }
        }
    }
}

// APERÇU POUR XCODE CANVAS
#Preview {
    AppointmentsListView()
        .environmentObject(AuthViewModel())
}
