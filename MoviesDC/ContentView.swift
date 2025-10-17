//
//  ContentView.swift
//  MovieDC
//
//  Created by Daniela Cuellar on 18/08/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context

    // Películas guardadas localmente (SwiftData)
    @Query(sort: [SortDescriptor(\MovieSD.createdAt, order: .reverse)], animation: .default)
    private var localMovies: [MovieSD]

    // Tu VM original (API + errores)
    @State var movieViewModel = MovieViewModel()

    // UI para crear/editar
    @State private var showForm = false
    @State private var movieToEdit: MovieSD? = nil

    // Evita importar más de una vez
    @State private var didAutoImport = false

    var body: some View {
        NavigationStack{
            VStack {
                if movieViewModel.isLoading {
                    ProgressView("loading movies...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

                } else if let err = movieViewModel.errorMessage {
                    VStack(spacing:12){
                        Text(err)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.red)

                        Button("Retry") { movieViewModel.retry() }
                            .buttonStyle(.borderedProminent)

                        Button("Importar de API a local") { importFromViewModel() }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

                } else {
                    // Fallback: si SwiftData está vacío pero la API ya tiene datos → muestra arrMovies
                    if localMovies.isEmpty && !movieViewModel.arrMovies.isEmpty {
                        List {
                            ForEach(movieViewModel.arrMovies) { item in
                                NavigationLink {
                                    MovieDetailView(movie: item)
                                } label: {
                                    MovieRowView(movie: item)
                                }
                            }
                        }
                    } else {
                        if localMovies.isEmpty {
                            ContentUnavailableView(
                                "Sin películas",
                                systemImage: "film",
                                description: Text("Toca + para crear una o ↻ para importar desde la API.")
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        } else {
                            List {
                                ForEach(localMovies){ item in
                                    NavigationLink {
                                        MovieDetailView(movie: Movie(
                                            name: item.name,
                                            imageName: item.imageName,
                                            description: item.details
                                        ))
                                    } label: {
                                        MovieRowView(movie: Movie(
                                            name: item.name,
                                            imageName: item.imageName,
                                            description: item.details
                                        ))
                                    }
                                    .swipeActions {
                                        Button("Editar") {
                                            movieToEdit = item
                                            showForm = true
                                        }
                                        .tint(.blue)

                                        // DELETE: API (opcional) + local
                                        Button(role: .destructive) {
                                            Task {
                                                do {
                                                    // Si no quieres borrar en API, comenta la línea de abajo y deja delete(item)
                                                    try await movieViewModel.deleteMovieAPI(identifier: item.name)
                                                    delete(item) // siempre borra local
                                                } catch {
                                                    movieViewModel.errorMessage = "No se pudo borrar en la API."
                                                }
                                            }
                                        } label: {
                                            Text("Borrar")
                                        }
                                    }
                                }
                                .onDelete(perform: deleteOffsets) // gesto nativo de borrar
                            }
                        }
                    }
                }
            }
            .navigationTitle("Películas")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        Task {
                            try? await movieViewModel.loadAPI()
                            importFromViewModel()
                        }
                    } label: { Image(systemName: "arrow.triangle.2.circlepath") }
                    .accessibilityLabel("Importar de API")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        movieToEdit = nil
                        showForm = true
                    } label: { Image(systemName: "plus") }
                    .accessibilityLabel("Agregar película")
                }
            }
            // Import automático al terminar la carga (una sola vez)
            .onChange(of: movieViewModel.isLoading) { _, isLoading in
                if !isLoading,
                   movieViewModel.errorMessage == nil,
                   !didAutoImport,
                   localMovies.isEmpty {
                    importFromViewModel()
                    didAutoImport = true
                }
            }
            // Formulario Crear/Editar → llama a la API y sincroniza SwiftData
            .sheet(isPresented: $showForm) {
                MovieFormView(movieToEdit: movieToEdit) { name, imageName, desc in
                    Task {
                        do {
                            if let m = movieToEdit {
                                // UPDATE en API
                                _ = try await movieViewModel.updateMovieAPI(
                                    originalName: m.name,
                                    name: name,
                                    imageName: imageName,
                                    description: desc
                                )
                                // sincroniza local
                                m.name = name
                                m.imageName = imageName
                                m.details = desc
                                try? context.save()
                            } else {
                                // CREATE en API
                                let created = try await movieViewModel.createMovieAPI(
                                    name: name,
                                    imageName: imageName,
                                    description: desc
                                )
                                // inserta espejo local
                                let local = MovieSD(name: created.name,
                                                    imageName: created.imageName,
                                                    details: created.description)
                                context.insert(local)
                                try? context.save()
                            }
                        } catch {
                            movieViewModel.errorMessage = "No se pudo guardar en la API."
                        }
                    }
                }
            }
        }
    }

    // -------- Helpers local (SwiftData) --------
    private func delete(_ m: MovieSD) {
        context.delete(m)
        try? context.save()
    }

    private func deleteOffsets(_ offsets: IndexSet) {
        for i in offsets { context.delete(localMovies[i]) }
        try? context.save()
    }

    private func importFromViewModel() {
        for r in movieViewModel.arrMovies {
            if !localMovies.contains(where: { $0.name == r.name && $0.imageName == r.imageName }) {
                let m = MovieSD(name: r.name,
                                imageName: r.imageName,
                                details: r.description)
                context.insert(m)
            }
        }
        try? context.save()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: MovieSD.self, inMemory: true)
}
