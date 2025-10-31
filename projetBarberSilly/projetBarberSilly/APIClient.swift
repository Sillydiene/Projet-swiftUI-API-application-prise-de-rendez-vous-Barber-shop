//
//  APIClient.swift
//  projetBarberSilly
//
//  Created by MacBook Pro Silly on 2025-10-22.
//

// APIClient.swift
import Foundation

//Représente le résultat brut d’un appel API
// On utilise un dictionnaire [String: Any] pour plus de flexibilité (utile avec MockAPI)
enum APIResult {
    case success([String: Any])  // Réponse réussie avec données
    case failure([String: Any])  // Réponse d’erreur
}

//Classe responsable de toutes les communications réseau avec l’API
final class APIClient {
    
    //Singleton (instance unique partagée)
    static let shared = APIClient()
    private init() {} // Empêche la création d’autres instances
    
    //URL de base pour toutes les requêtes API
    private let base = URL(string: "https://68f26a1bb36f9750deec8d45.mockapi.io/api/v1")!
    
    
    func register(name: String, email: String, password: String) async throws -> User {
        let url = base.appendingPathComponent("users") // /users endpoint
        
        // Construction de la requête POST
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Corps de la requête encodé en JSON
        let body = ["name": name, "email": email, "password": password]
        req.httpBody = try JSONEncoder().encode(body)
        
        // Exécution de la requête
        let (data, _) = try await URLSession.shared.data(for: req)
        
        // Décodage en un objet `User`
        return try JSONDecoder().decode(User.self, from: data)
    }

    func login(email: String, password: String, completion: @escaping (APIResult) -> Void) {
        // Vérifie que l’URL est valide
        guard let url = URL(string: "\(base)/users") else {
            completion(.failure(["error": "URL invalide"]))
            return
        }

        // Prépare une requête GET
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Exécute la requête de manière asynchrone
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            //Gestion d’erreur réseau
            if let _ = error {
                completion(.failure(["error": "Erreur réseau."]))
                return
            }
            
            //Vérifie la présence de données
            guard let data = data else {
                completion(.failure(["error": "Aucune donnée reçue."]))
                return
            }
            
            //Vérifie le code HTTP
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                completion(.failure(["error": "HTTP \(http.statusCode): Not found."]))
                return
            }
            
            //Décodage du JSON retourné par MockAPI
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    
                    // Recherche de l’utilisateur correspondant à l’email et au mot de passe
                    if let user = jsonArray.first(where: {
                        ($0["email"] as? String)?.lowercased() == email.lowercased() &&
                        ($0["password"] as? String) == password
                    }) {
                        // Simule un token d’authentification
                        var result = user
                        result["token"] = "fake_token_123"
                        completion(.success(result))
                    } else {
                        completion(.failure(["error": "Identifiants invalides"]))
                    }
                    
                } else {
                    completion(.failure(["error": "Format JSON inattendu."]))
                }
            } catch {
                completion(.failure(["error": "Impossible de parser la réponse JSON."]))
            }
        }
        .resume()
    }

    func fetchAppointments(for userId: String) async throws -> [Appointment] {
        // Prépare les paramètres de requête (ex: ?userId=123)
        var comps = URLComponents(url: base.appendingPathComponent("appointments"), resolvingAgainstBaseURL: false)!
        comps.queryItems = [URLQueryItem(name: "userId", value: userId)]
        
        // Envoie la requête GET
        let url = comps.url!
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Utilise un décodeur compatible ISO 8601 (dates)
        let decoder = JSONDecoder.iso8601Decoder
        // Trie les rendez-vous par date croissante
        return try decoder.decode([Appointment].self, from: data).sorted { $0.date < $1.date }
    }

  
    func createAppointment(_ a: Appointment) async throws -> Appointment {
        let url = base.appendingPathComponent("appointments")
        
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Encode la requête avec un encodeur ISO 8601 (dates incluses)
        let encoder = JSONEncoder.iso8601Encoder
        req.httpBody = try encoder.encode(a)

        let (data, _) = try await URLSession.shared.data(for: req)
        let decoder = JSONDecoder.iso8601Decoder
        return try decoder.decode(Appointment.self, from: data)
    }

  
    func updateAppointment(_ a: Appointment) async throws -> Appointment {
        let url = base.appendingPathComponent("appointments/\(a.id)")
        
        var req = URLRequest(url: url)
        req.httpMethod = "PUT"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder.iso8601Encoder
        req.httpBody = try encoder.encode(a)

        let (data, _) = try await URLSession.shared.data(for: req)
        let decoder = JSONDecoder.iso8601Decoder
        return try decoder.decode(Appointment.self, from: data)
    }

  
    func deleteAppointment(id: String) async throws {
        let url = base.appendingPathComponent("appointments/\(id)")
        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        _ = try await URLSession.shared.data(for: req)
    }
}
