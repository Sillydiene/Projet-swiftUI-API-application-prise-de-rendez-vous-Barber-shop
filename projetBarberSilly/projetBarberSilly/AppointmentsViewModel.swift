//
//  AppointmentsViewModel.swift
//  projetBarberSilly
//
//  Created by MacBook Pro Silly on 2025-10-22.
//

// AppointmentsViewModel.swift
import Foundation
import Combine
import SwiftUI

//ViewModel principal pour gérer la logique des rendez-vous
// Il relie la couche réseau (APIClient) à la couche interface (SwiftUI)
// Toutes les propriétés sont observables pour permettre une mise à jour automatique de l’interface.
@MainActor // Garantit que toutes les mises à jour d’interface se font sur le thread principal
final class AppointmentsViewModel: ObservableObject {
    
    // Liste des rendez-vous affichés dans la vue
    @Published var items: [Appointment] = []
    
    // Indicateur de chargement (affiche un spinner)
    @Published var isLoading = false
    
    //Message d’erreur à afficher en cas de problème réseau ou décodage
    @Published var error: String? = nil

    func load(userId: String) async {
        isLoading = true
        error = nil
        do {
            // Appel au client API pour récupérer la liste des rendez-vous
            items = try await APIClient.shared.fetchAppointments(for: userId)
        } catch {
            // En cas d’erreur réseau ou JSON, on la capture
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func add(userId: String, title: String, notes: String?, date: Date) async {
        // Création locale d’un objet temporaire avec un UUID
        let tmp = Appointment(id: UUID().uuidString, title: title, notes: notes, date: date, userId: userId)
        
        do {
            // Envoi au serveur pour création réelle
            let created = try await APIClient.shared.createAppointment(tmp)
            
            // Ajout dans la liste locale et tri chronologique
            items.append(created)
            items.sort { $0.date < $1.date }
        } catch {
            // Capture et affichage d’erreur
            self.error = error.localizedDescription
        }
    }

    func update(_ a: Appointment) async {
        do {
            // Appel API PUT
            let updated = try await APIClient.shared.updateAppointment(a)
            
            // Remplace l’ancienne version dans la liste locale
            if let idx = items.firstIndex(where: { $0.id == updated.id }) {
                items[idx] = updated
                items.sort { $0.date < $1.date }
            }
        } catch {
            self.error = error.localizedDescription
        }
    }


    func delete(at offsets: IndexSet) async {
        for index in offsets {
            let id = items[index].id
            do {
                // Appel à l’API pour suppression côté serveur
                try await APIClient.shared.deleteAppointment(id: id)
            } catch {
                self.error = error.localizedDescription
            }
        }
        // Mise à jour locale (supprime de la liste)
        items.remove(atOffsets: offsets)
    }

  
    func deleteOne(_ appt: Appointment) async {
        do {
            // Suppression sur le serveur
            try await APIClient.shared.deleteAppointment(id: appt.id)
            // Suppression dans la liste locale
            items.removeAll { $0.id == appt.id }
        } catch {
            self.error = error.localizedDescription
        }
    }
}
