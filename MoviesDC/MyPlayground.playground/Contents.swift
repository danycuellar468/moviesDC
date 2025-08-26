import SwiftUI

var arrMovies = [Movie]()

struct Movie : Identifiable, Decodable {
    var id = UUID()
    var name : String
    var description: String
    var videoURL : String
    var imageName : [String]
    
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case imageName
    }
}

func loadMovie() async throws -> [Movie] {
    let url = URL(string: "https://movies-api-wgms.onrender.com/movies")
    let(data, _) = try await URLSession.shared.data(from: url!)
    let movies = try JSONDecoder().decode([Movie].self, from: data)
    
    return movies
}

Task {

    arrMovies = try await loadMovie()
    
    arrMovies.forEach { item in
        print(item.name)
    }
}

