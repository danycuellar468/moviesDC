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
                    // ✅ Fallback: si SwiftData vacío pero API sí tiene datos → mostrar arrMovies
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
                    }
                    // ✅ Normal: mostrar los datos guardados en SwiftData
                    else {
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

                                        Button(role: .destructive) {
                                            delete(item)
                                        } label: {
                                            Text("Borrar")
                                        }
                                    }
                                }
                                .onDelete(perform: deleteOffsets)
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
            // ✅ Import automático al terminar la carga (una sola vez)
            .onChange(of: movieViewModel.isLoading) { _, isLoading in
                if !isLoading,
                   movieViewModel.errorMessage == nil,
                   !didAutoImport,
                   localMovies.isEmpty {
                    importFromViewModel()
                    didAutoImport = true
                }
            }
            // Formulario Crear/Editar
            .sheet(isPresented: $showForm) {
                MovieFormView(movieToEdit: movieToEdit) { name, imageName, desc in
                    if let m = movieToEdit {
                        m.name = name
                        m.imageName = imageName
                        m.details = desc
                    } else {
                        let m = MovieSD(name: name, imageName: imageName, details: desc)
                        context.insert(m)
                    }
                    try? context.save()
                }
            }
        }
    }

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
