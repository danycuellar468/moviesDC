//
//  MovieFromView.swift
//  MoviesDC
//
//  Created by Alumno on 29/09/25.
//

import SwiftUI

struct MovieFormView: View {
    var movieToEdit: MovieSD? = nil
    var onSave: (_ name: String, _ imageName: String, _ desc: String) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var imageName: String = ""
    @State private var desc: String = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Nombre", text: $name)
                TextField("Imagen (asset)", text: $imageName)
                TextField("Descripción", text: $desc, axis: .vertical)
                    .lineLimit(3...6)
                Button(movieToEdit == nil ? "Guardar" : "Actualizar") {
                    onSave(name, imageName, desc)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle(movieToEdit == nil ? "Nueva película" : "Editar película")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cerrar") { dismiss() } }
            }
            .onAppear {
                if let m = movieToEdit {
                    name = m.name
                    imageName = m.imageName
                    desc = m.details
                }
            }
        }
    }
}
