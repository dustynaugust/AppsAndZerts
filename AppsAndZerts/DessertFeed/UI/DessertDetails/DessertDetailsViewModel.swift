//
//  DessertDetailsViewModel.swift
//  AppsAndZertsTests
//
//  Created by Dustyn August on 1/26/24.
//

import Foundation
import HTTPService

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
    private let httpService: URLSessionHTTPService<DessertDetailsItem>
    
    var isLoading: Bool { state == .loading }
    
    init(
        mealID: String
    ) {
        state = .loading
        self.mealID = mealID
        
        httpService = URLSessionHTTPService(
            for:  DessertFeedEndpoints.get(mealID: mealID).urlRequest,
            map: DessertDetailsItemMapper.map
        )
    }
    
    @MainActor
    func getDetails() async {
        do {
            state = .loading
            
            let resource = try await httpService.loadResource()
            
            state = .loaded(resource)
            
        } catch {
            state = .error
        }
    }
}
