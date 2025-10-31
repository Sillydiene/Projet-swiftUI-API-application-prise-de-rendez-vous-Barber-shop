//
//  AppointmentEditorView.swift
//  projetBarberSilly
//
//  Created by MacBook Pro Silly on 2025-10-22.
//

// AppointmentEditorView.swift
import SwiftUI

//  Enum qui représente le résultat possible de l'éditeur de rendez-vous
// - created : un nouveau rendez-vous a été créé
// - updated : un rendez-vous existant a été modifié
// - cancelled : l’utilisateur a annulé sans enregistrer
enum EditorResult {
    case created(AppointmentDraft)
    case updated(Appointment)
    case cancelled
}

// Structure temporaire servant de brouillon avant la création d’un rendez-vous
// (utile pour stocker les données saisies par l’utilisateur)
struct AppointmentDraft {
    var title: String = ""      // Titre du rendez-vous
    var notes: String = ""      // Notes facultatives
    var date: Date = .now       // Date et heure du rendez-vous
}

// Vue SwiftUI permettant de créer ou modifier un rendez-vous
struct AppointmentEditorView: View {
    
    // Données reçues depuis l’extérieur
    let user: User                    // Utilisateur associé au rendez-vous
    let appointment: Appointment?     // Rendez-vous à modifier (nil si nouveau)
    var onDone: (EditorResult) -> Void // Callback pour signaler le résultat à la vue appelante

    // Environnement et état interne
    @Environment(\.dismiss) private var dismiss     // Permet de fermer la vue
    @State private var draft = AppointmentDraft()   // Contient les données saisies par l’utilisateur

    // Indique si on est en mode édition (si un rendez-vous est fourni)
    var isEditing: Bool { appointment != nil }

    //  Initialisation personnalisée de la vue
    // Si un rendez-vous existe, les champs du brouillon sont pré-remplis
    init(user: User, appointment: Appointment?, onDone: @escaping (EditorResult) -> Void) {
        self.user = user
        self.appointment = appointment
        self.onDone = onDone
        _draft = State(initialValue: AppointmentDraft(
            title: appointment?.title ?? "",
            notes: appointment?.notes ?? "",
            date: appointment?.date ?? Date()
        ))
    }

    //  Corps principal de la vue
    var body: some View {
        NavigationStack {
            ZStack {
                // IMAGE DE FOND
                Image("barber_bgg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                // Voile sombre pour un meilleur contraste avec le texte blanc
                Color.black.opacity(0.6)
                    .ignoresSafeArea()

                // FORMULAIRE DE SAISIE
                Form {
                    Section {
                        // Champ pour le titre du rendez-vous
                        TextField("Titre", text: $draft.title)
                            .foregroundColor(.white)
                            .colorScheme(.dark) //Force le texte en mode sombre
                            .listRowBackground(Color.white.opacity(0.1))

                        // Champ pour les notes facultatives
                        TextField("Notes (optionnel)", text: $draft.notes)
                            .foregroundColor(.white)
                            .colorScheme(.dark)
                            .listRowBackground(Color.white.opacity(0.1))

                        // Sélecteur de date et heure
                        DatePicker(
                            "Date & heure",
                            selection: $draft.date,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .foregroundColor(.white)
                        .colorScheme(.dark)
                        .listRowBackground(Color.white.opacity(0.1))
                    }
                }
                //Supprime l’arrière-plan par défaut de la liste pour garder l’image visible
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }

            // BARRE DE NAVIGATION
            .navigationTitle(isEditing ? "Modifier" : "Nouveau RDV") // Titre dynamique
            .navigationBarTitleDisplayMode(.inline) // Titre centré compact

            // 🎨 Personnalisation visuelle de la barre de navigation
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black.opacity(0.8), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)

            //BOUTONS D’ACTION
            .toolbar {
                
                // Bouton pour annuler l’édition
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        onDone(.cancelled) // Informe la vue parent
                        dismiss()          // Ferme la vue
                    }
                    .foregroundColor(.white)
                }

                // Bouton pour enregistrer ou créer un rendez-vous
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Enregistrer" : "Créer") {
                        // Si on modifie un rendez-vous existant
                        if var appt = appointment {
                            appt.title = draft.title
                            appt.notes = draft.notes.isEmpty ? nil : draft.notes
                            appt.date = draft.date
                            onDone(.updated(appt)) // Retourne le rendez-vous modifié
                        } else {
                            // Si c’est une création
                            let created = AppointmentDraft(
                                title: draft.title,
                                notes: draft.notes,
                                date: draft.date
                            )
                            onDone(.created(created)) // Retourne le nouveau brouillon
                        }
                        dismiss() // Ferme la vue après action
                    }
                    .foregroundColor(.white)
                    //Désactive le bouton si le titre est vide
                    .disabled(draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }

        }
    }
}

//Aperçu dans le Canvas de Xcode pour test visuel
#Preview {
    // Exemple de données fictives pour la prévisualisation
    let fakeUser = User(id: "1", name: "Test User", email: "test@mail.com")
    let fakeAppointment = Appointment(
        id: "1",
        title: "Rendez-vous test",
        notes: "Note de test",
        date: Date(),
        userId: "1"
    )

    // Vue simulée avec un callback vide (aucune action réelle)
    return AppointmentEditorView(
        user: fakeUser,
        appointment: fakeAppointment,
        onDone: { _ in }
    )
    .environment(\.colorScheme, .dark) // Mode sombre pour visualisation correcte
}
