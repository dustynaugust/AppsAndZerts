//
//  FeedViewModel.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/24/24.
//

import Foundation
import HTTPService

class FeedViewModel: ObservableObject {
    typealias Feed = [FeedItem]
    
    enum FeedState: Equatable {
        case loading
        case loaded(Feed)
        case error
    }
    
    private(set) var feedState: FeedState {
        willSet { showingAlert = newValue == .error }
    }
    
    @Published var showingAlert = false
    private let httpService: URLSessionHTTPService<Feed>
    private let resourceType: ResourceType
    
    var isLoading: Bool { feedState == .loading }
    
    var feed: Feed {
        switch feedState {
        case .loading,
                .error:
            return []
            
        case let .loaded(feed):
            return feed
        }
    }
    
    var alertTitle: String {
        "Failed to retrieve \(navigationTitle)"
    }
    
    var navigationTitle: String {
        switch resourceType {
        case .dessert:
            return "Desserts"
            
        case .appetizer:
            return "Appetizers"
        }
    }
    
    
    
    var detail: (title: String, systemImage: String) {
        switch resourceType {
        case .dessert:
            return (title: "Woo, Desserts!", systemImage: "birthday.cake")
            
        case .appetizer:
            return (title: "Woo, Appetizers!", systemImage: "fork.knife")
        }
    }
    
    init(
        resourceType: ResourceType
    ) {
        feedState = .loading
        
        self.resourceType = resourceType
        httpService = URLSessionHTTPService(
            for: FeedEndpoint.getAll(.dessert).urlRequest,
            map: FeedItemsMapper.map
        )
    }
    
    @MainActor
    func getFeed() async {
        do {
            feedState = .loading
            
            var resource = try await httpService.loadResource()
            
            resource.sort { $0.name < $1.name }
            feedState = .loaded(resource)
            
        } catch {
            feedState = .error
        }
    }
}
