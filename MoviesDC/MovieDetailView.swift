//
//  MovieDetailView.swift
//  MovieDC
//
//  Created by Alumno on 18/08/25.
//

import SwiftUI
import SwiftData

struct MovieDetailView: View {
    
    let movie: Movie
    
    var body: some View {
        
        VStack{
            //uses local images to placeholder if missing
            Image(movie.imageName)
                .resizable()
                .scaledToFit()
            
            Text(movie.name)
                .font(.title)
                .bold()

            Text(movie.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        
    }
}

#Preview {
    MovieDetailView(movie:Movie(name: "Freaky Friday", imageName: "FreakyFriday", description: "An overworked mother and her daughter do not get along. When they switch bodies, each is forced to adapt to the other's life for one freaky Friday."))
}
