//
//  PlaceViewModel.swift
//  PlacesDC
//
//  Created by Alumno on 18/08/25.
//

import Foundation
import Observation

@MainActor
@Observable
class MovieViewModel {
    // Data
    var arrMovies = [Movie]()
    var isLoading: Bool = false
    var errorMessage: String? = nil

    init(){
        Task { try await loadAPI() }
    }

    // -------- READ --------
    func loadAPI() async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        guard let url = URL(string: "\(baseURL)/movies") else {
            errorMessage = "Invalid URL"
            return
        }

        do {
            var urlRequest = URLRequest(url: url)
            urlRequest.timeoutInterval = 20
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard let code = (response  as? HTTPURLResponse)?.statusCode, (200..<300).contains(code) else{
                errorMessage = "Unknown answer for the server"
                return
            }
            let results = try JSONDecoder().decode([Movie].self, from: data)
            self.arrMovies = results

        } catch let urlErr as URLError {
            switch urlErr.code {
            case .notConnectedToInternet:
                errorMessage = "It seems like you are not connected to the internet."
            case .timedOut:
                errorMessage = "The request timed out."
            case .cannotFindHost, .cannotConnectToHost:
                errorMessage = "The server could not be reached."
            default:
                errorMessage = "An unknown error occurred."
            }
        } catch is DecodingError {
            errorMessage = "Couldn't read the data from the API."
            print("Decoding error")
        } catch {
            errorMessage = "Something went wrong."
        }
    }

    func retry(){
        Task { try await loadAPI() }
    }
}

// MARK: - API Create/Update/Delete
extension MovieViewModel {
    // Cambia esto si tu dominio/base es otro
    fileprivate var baseURL: String { "https://movies-api-wgms.onrender.com" }

    private struct APIMoviePayload: Codable {
        let name: String
        let imageName: String
        let description: String
    }

    // CREATE → POST /movies
    @discardableResult
    func createMovieAPI(name: String, imageName: String, description: String) async throws -> Movie {
        guard let url = URL(string: "\(baseURL)/movies") else { throw URLError(.badURL) }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.timeoutInterval = 20
        req.httpBody = try JSONEncoder().encode(APIMoviePayload(name: name, imageName: imageName, description: description))

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let code = (resp as? HTTPURLResponse)?.statusCode, (200..<300).contains(code) else {
            throw URLError(.badServerResponse)
        }

        return (try? JSONDecoder().decode(Movie.self, from: data))
            ?? Movie(name: name, imageName: imageName, description: description)
    }

    // UPDATE → PUT /movies/{original_name}
    @discardableResult
    func updateMovieAPI(originalName: String, name: String, imageName: String, description: String) async throws -> Movie {
        let encoded = originalName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? originalName
        guard let url = URL(string: "\(baseURL)/movies/\(encoded)") else { throw URLError(.badURL) }
        var req = URLRequest(url: url)
        req.httpMethod = "PUT"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.timeoutInterval = 20
        req.httpBody = try JSONEncoder().encode(APIMoviePayload(name: name, imageName: imageName, description: description))

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let code = (resp as? HTTPURLResponse)?.statusCode, (200..<300).contains(code) else {
            throw URLError(.badServerResponse)
        }

        return (try? JSONDecoder().decode(Movie.self, from: data))
            ?? Movie(name: name, imageName: imageName, description: description)
    }

    // DELETE (opcional) → DELETE /movies/{name}
    func deleteMovieAPI(identifier nameOrId: String) async throws {
        let encoded = nameOrId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? nameOrId
        guard let url = URL(string: "\(baseURL)/movies/\(encoded)") else { throw URLError(.badURL) }
        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        req.timeoutInterval = 20

        let (_, resp) = try await URLSession.shared.data(for: req)
        guard let code = (resp as? HTTPURLResponse)?.statusCode, (200..<300).contains(code) else {
            throw URLError(.badServerResponse)
        }
    }
}
