//
//  MovieSD.swift
//  MoviesDC
//
//  Created by Alumno on 29/09/25.
//

import Foundation
import SwiftData

// Modelo LOCAL para persistencia con SwiftData.
// NOTA: 'description' nombre reservado por @Model → usamos 'details'.
@Model
final class MovieSD {
    // Si quieres un id propio, puedes agregarlo:
    // var id: UUID  = UUID()

    var name: String
    var imageName: String
    var details: String
    var createdAt: Date

    // Constructor simple
    init(name: String, imageName: String, details: String) {
        self.name = name
        self.imageName = imageName
        self.details = details
        self.createdAt = .now
    }
}
