//
//  EditView-ViewModel.swift
//  BucketList
//
//  Created by melo on 5/9/23.
//

import Foundation
import SwiftUI

extension EditView {
    @MainActor class ViewModel: ObservableObject {
        @Published var location: Location
        
        @Published var name: String
        @Published var description: String
        @Published var pages = [Page]()
        @Published var loadingState = LoadingState.loading
        
        enum LoadingState {
            case loading, loaded, failed
        }

        init(location: Location) {
            self.location = location
            _name = Published(initialValue: location.name)
            _description = Published(initialValue: location.description)
        }
        
        func fetchNearbyPlaces() async {
            let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(location.coordinate.latitude)%7C\(location.coordinate.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"
            
            guard let url = URL(string: urlString) else {
                print("bad URL: \(urlString)")
                return
            }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                // we got some data back!
                let items = try JSONDecoder().decode(Result.self, from: data)
                // success - convert the array values to our pages array
                pages = items.query.pages.values.sorted()
                loadingState = .loaded
            } catch {
                loadingState = .failed
            }
        }
    }
}
