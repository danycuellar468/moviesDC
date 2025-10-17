//
//  Movies.swift
//  MoviesDC
//
//  Created by Alumno on 18/08/25.
//

import Foundation

struct Movie: Identifiable, Decodable {
    // La API no manda id, generamos uno
    var id = UUID()
    var name: String
    var imageName: String
    var description: String

    enum CodingKeys: String, CodingKey {
        case name
        case imageName
        case description
    }
}



