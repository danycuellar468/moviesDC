//
//  Movies.swift
//  MoviesDC
//
//  Created by Alumno on 18/08/25.
//

import Foundation

//clean code - consistent naming
//Movie model mathces the API response
struct Movie: Identifiable, Decodable{
    //The API doesn't send an ID so we generate one locally
    var id = UUID()
    var name: String
    var imageName: String
    var description: String
    
    //coding keys with the variables that I use on the API
    enum CodingKeys: String, CodingKey {
        case name
        case imageName
        case description
    }
}
