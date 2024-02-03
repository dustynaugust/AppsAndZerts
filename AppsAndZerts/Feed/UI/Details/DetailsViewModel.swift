//
//  DetailsViewModel.swift
//  AppsAndZertsTests
//
//  Created by Dustyn August on 1/26/24.
//

import Foundation
import HTTPService

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
    private let httpService: URLSessionHTTPService<DetailsItem>
    private let mealID: String
    
    var isLoading: Bool { state == .loading }
    
    init(
        mealID: String
    ) {
        state = .loading
        self.mealID = mealID
        
        httpService = URLSessionHTTPService(
            for:  FeedEndpoint.get(mealID: mealID).urlRequest,
            map: DetailsItemMapper.map
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
