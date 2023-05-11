//
//  ContentView.swift
//  Places
//
//  Created by melo on 4/6/23.
//

import SwiftUI
import MapKit
import LocalAuthentication

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    
    @State private var didAuthError = false
    @State private var authErrorMessage: String?
    @State private var didClickClearButton = false
    @State private var didTryAddingDuplicatePlace = false

    var body: some View {
        ZStack {
            if viewModel.isUnlocked {
                Map(coordinateRegion: $viewModel.mapRegion, annotationItems: viewModel.locations) { location in
                    MapAnnotation(coordinate: location.coordinate) {
                        VStack {
                            Image(systemName: "star.circle")
                                .resizable()
                                .foregroundColor(.red)
                                .frame(width: 44, height: 44)
                                .background(.white)
                                .clipShape(Circle())
                            Text(location.name)
                                .fixedSize()
                        }
                        .onTapGesture {
                            viewModel.selectedPlace = location
                        }
                    }
                }
                .ignoresSafeArea()
                Circle()
                    .fill(.blue)
                    .opacity(0.3)
                    .frame(width: 32, height: 32)
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            didClickClearButton = true
                        } label: {
                            Image(systemName: "trash.fill")
                                .padding()
                                .background(.red.opacity(0.75))
                                .foregroundColor(.white)
                                .font(.title3)
                                .clipShape(Circle())
                                .padding(.trailing)
                        }
                        .confirmationDialog("Delete all places", isPresented: $didClickClearButton) {
                            Button("Delete all places", role: .destructive) {
                                viewModel.deleteAllPlaces()
                            }
                            Button("Cancel", role: .cancel) {
                                didClickClearButton = false
                            }
                        }
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            viewModel.addLocation { success in
                                didTryAddingDuplicatePlace = !success
                            }
                        } label: {
                            Image(systemName: "plus")
                                .padding()
                                .background(.black.opacity(0.75))
                                .foregroundColor(.white)
                                .font(.title)
                                .clipShape(Circle())
                                .padding(.trailing)
                        }
                    }
                }
            } else {
                Button {
                    viewModel.authenticate { errorMessage in
                        if errorMessage != "" {
                            authErrorMessage = errorMessage
                            didAuthError = true
                        }
                    }
                } label: {
                    Text("unlock places")
                        .padding()
                        .background(.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
        }
        .sheet(item: $viewModel.selectedPlace) { place in
            EditView(location: place) {
                viewModel.update(location: $0)
            }
        }
        .alert(isPresented: $didTryAddingDuplicatePlace, content: {
            Alert(title: Text("Place already in collection"))
        })
        .alert(
            authErrorMessage ?? "No error message",
            isPresented: $didAuthError
        ) {
            Button("OK") { }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
