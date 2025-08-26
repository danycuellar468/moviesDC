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
    //Data
    var arrMovies = [Movie]()
    
    var isLoading: Bool = false //show loading indicator
    var errorMessage: String? = nil //store error messages
    
    
    init(){
        //clean code - no dead code, we call only what we use
        //automatically load movies when ViewModel is created
        Task{
            try await loadAPI()
        }
        
    }
    
    // Loads the movies from my API
    //Show UI frendly error messages
    func loadAPI() async throws {
        isLoading = true
        errorMessage = nil
        defer {isLoading = false} //always stop loading at the end
        
        guard let url = URL(string: "https://movies-api-wgms.onrender.com/movies") else {
            errorMessage = "Invalid URL"
            return
        }
        
        do{
            //create the request with a timeout
            var urlRequest = URLRequest(url: url)
            urlRequest.timeoutInterval = 20
            
            //perform request
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            //validate http response
            guard let code = (response  as? HTTPURLResponse)?.statusCode, (200..<300).contains(code) else{
                errorMessage = "Unknown answer for the server"
                return
            }
            //decode json into movie array
            let results = try JSONDecoder().decode([Movie].self, from: data)
            self.arrMovies = results
            
        } catch let urlErr as URLError{
            //clean code - friendly messages with no crashes
            //handle common errors
            switch urlErr.code{
            case .notConnectedToInternet:
                errorMessage = "It seems like you are not connected to the internet."
            case.timedOut:
                errorMessage = "The request timed out."
            case.cannotFindHost, .cannotConnectToHost:
                errorMessage = "The server could not be reached."
            default:
                errorMessage = "An unknown error occurred."
            }
        }catch is DecodingError{
            errorMessage = "Couldn't read the data from the API."
            print("Decoding error")
        }catch {
            //for any other unexpected error
            errorMessage = "Something went wrong."
        }
        
    }

    //retry button to reload the API
    func retry(){
        Task{
            try await loadAPI()
        }
    }
}


