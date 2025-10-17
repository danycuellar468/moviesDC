//
//  MoviesDCTests.swift
//  MoviesDCTests
//
//  Created by Alumno on 17/10/25.
//

import Testing
import Foundation        // for String trimming
import SwiftData
@testable import MoviesDC

// Unit Test (name validation)
private extension MovieSD {
    static func isValidName(_ name: String) -> Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

struct MoviesDCSwiftTests {
    // Test 1: validate that the name isn't empty or spaces.
    @Test("Movie name must not be empty or whitespace")
    func testNameValidation() {
        #expect(MovieSD.isValidName("Interstellar"))     // válido
        #expect(!MovieSD.isValidName(""))                // vacío
        #expect(!MovieSD.isValidName("   "))             // solo espacios
    }

    // Test 2: CRUD with SwiftData in memory
    @Test("CRUD in-memory with SwiftData (create/read/update/delete)")
    @MainActor
    func testCRUDInMemory() throws {
        // container in memory
        let container = try ModelContainer(
            for: MovieSD.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let ctx = container.mainContext

        // CREATE
        let m = MovieSD(name: "Test", imageName: "FreakyFriday", details: "demo")
        ctx.insert(m)
        try ctx.save()

        // READ
        var all = try ctx.fetch(FetchDescriptor<MovieSD>())
        var match = all.first(where: { $0.name == "Test" })
        #expect(match != nil)

        // UPDATE
        match?.details = "editado"
        try ctx.save()
        all = try ctx.fetch(FetchDescriptor<MovieSD>())
        match = all.first(where: { $0.name == "Test" })
        #expect(match?.details == "editado")

        // DELETE
        if let toDelete = match {
            ctx.delete(toDelete)
            try ctx.save()
        }
        all = try ctx.fetch(FetchDescriptor<MovieSD>())
        #expect(!all.contains(where: { $0.name == "Test" }))
    }
}

