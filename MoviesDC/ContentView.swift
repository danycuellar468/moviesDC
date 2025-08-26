//
//  ContentView.swift
//  MovieDC
//
//  Created by Daniela Cuellar on 18/08/25.
//

import SwiftUI

struct ContentView: View {
    @State var movieViewModel = MovieViewModel()
    
    var body: some View {
        
        NavigationStack{
            
            VStack {
                if movieViewModel.isLoading{
                    //show loading indicator
                    ProgressView("loading movies...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                else if let err = movieViewModel.errorMessage{
                    //show error messages
                    VStack(spacing:12){
                        Text(err)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.red)
                        Button("Retry"){
                            movieViewModel.retry()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    
                    List{
                        ForEach(movieViewModel.arrMovies){item in
                            NavigationLink {
                                MovieDetailView(movie: item)
                            } label: {
                                MovieRowView(movie: item)
                            }
                        }
                    }
                }
            } .navigationTitle("Películas")
        }
    }
}

#Preview {
    ContentView()
}
