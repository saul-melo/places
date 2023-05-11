//
//  EditView.swift
//  Places
//
//  Created by melo on 4/19/23.
//

import SwiftUI

struct EditView: View {
    @StateObject private var viewModel: ViewModel
    
    @Environment(\.dismiss) var dismiss
    
    var onSave: (Location) -> Void
    
    init(location: Location, onSave: @escaping (Location) -> Void) {
        self.onSave = onSave
        
        _viewModel = StateObject(wrappedValue: ViewModel(location: location))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("place name", text: $viewModel.name)
                    TextField("description", text: $viewModel.description)
                }
                Section("nearby…") {
                    switch viewModel.loadingState {
                    case .loaded:
                        ForEach(viewModel.pages, id: \.pageid) { page in
                            Text(page.title)
                                .font(.headline)
                            + Text(": ") +
                            Text(page.description)
                                .italic()
                        }
                    case .loading:
                        Text("loading…")
                    case .failed:
                        Text("please try again later.")
                    }
                }
            }
            .navigationTitle("place details")
            .toolbar {
                Button("save") {
                    var newLocation = viewModel.location
                    newLocation.id = UUID()
                    newLocation.name = viewModel.name
                    newLocation.description = viewModel.description
                    
                    onSave(newLocation)
                    dismiss()
                }
            }
            .task {
                await viewModel.fetchNearbyPlaces()
            }
        }
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(location: Location.example) { newLocation in }
    }
}
