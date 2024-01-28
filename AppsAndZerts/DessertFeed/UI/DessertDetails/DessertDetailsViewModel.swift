//
//  DessertDetailsViewModel.swift
//  AppsAndZertsTests
//
//  Created by Dustyn August on 1/26/24.
//

import Foundation

class DessertDetailsViewModel: ObservableObject {
    enum State: Equatable {
        case loading
        case loaded(DessertDetailsItem)
        case error
    }
    
    @Published private(set) var state: State {
        willSet {
            showingAlert = newValue == .error
        }
    }
    
    @Published var showingAlert = false
    private let mealID: String
    private let resourceLoader: ResourceLoader<DessertDetailsItem>
    
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
                from: DessertFeedEndpoints.get(mealID: mealID).urlRequest,
                map: DessertDetailsItemMapper.map
            )
            
            state = .loaded(resource)
            
        } catch {
            state = .error
        }
    }
}
