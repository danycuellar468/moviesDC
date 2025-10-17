//
//  MovieDCApp.swift
//  MovieDC
//
//  Created by Alumno on 18/08/25.
//

import SwiftUI
import SwiftData

@main
struct MovieDCApp: App {
    // contenedor de SwiftData
    private var container: ModelContainer = {
        do {
            let cfg = ModelConfiguration(isStoredInMemoryOnly: false)
            return try ModelContainer(for: MovieSD.self, configurations: cfg)
        } catch {
            fatalError("No se pudo crear ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}



