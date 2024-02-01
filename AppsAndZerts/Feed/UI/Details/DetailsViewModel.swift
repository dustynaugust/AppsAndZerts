//
//  DetailsViewModel.swift
//  AppsAndZertsTests
//
//  Created by Dustyn August on 1/26/24.
//

import Foundation

class DetailsViewModel: ObservableObject {
    enum State: Equatable {
        case loading
        case loaded(DetailsItem)
        case error
    }
    
    @Published private(set) var state: State {
        willSet {
            showingAlert = newValue == .error
        }
    }
    
    @Published var showingAlert = false
    private let mealID: String
    private let resourceLoader: ResourceLoader<DetailsItem>
    
    var isLoading: Bool { state == .loading }
    
    init(
        mealID: String
    ) {
        state = .loading
        self.mealID = mealID
        
        resourceLoader = ResourceLoader(
            dataLoader: URLSession.shared.data(for:)
        )
    }
    
    @MainActor
    func getDetails() async {
        do {
            state = .loading
            
            let resource = try await resourceLoader.loadResource(
                from: FeedEndpoint.get(mealID: mealID).urlRequest,
                map: DetailsItemMapper.map
            )
            
            state = .loaded(resource)
            
        } catch {
            state = .error
        }
    }
}
