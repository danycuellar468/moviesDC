//
//  MovieRowView.swift
//  MovieDC
//
//  Created by Alumno on 18/08/25.
//

import SwiftUI

struct MovieRowView: View {
    
    let movie : Movie
    
    var body: some View {
        //shows movie poster
        HStack{
            Image(movie.imageName)
                .resizable()
                .scaledToFit()
                .frame(width:100)
            Text(movie.name)
        }
    }
}
#Preview {
    MovieRowView(movie: Movie(name:"Freaky Friday", imageName: "FreakyFriday", description: "An overworked mother and her daughter do not get along. When they switch bodies, each is forced to adapt to the other's life for one freaky Friday."))
}
