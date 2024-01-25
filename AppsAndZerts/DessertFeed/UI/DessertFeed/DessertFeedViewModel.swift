//
//  DessertFeedViewModel.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/24/24.
//

import Foundation

class DessertFeedViewModel: ObservableObject {
    typealias Feed = [DessertFeedItem]
    
    enum FeedState: Equatable {
        case loading
        case loaded(Feed)
        case error
    }
    
    @Published private(set) var feedState: FeedState {
        willSet {
            showingAlert = newValue == .error
        }
    }
    
    @Published var showingAlert = false
    
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
    
    private let resourceLoader: ResourceLoader<Feed>
    
    init() {
        feedState = .loading
        
        resourceLoader = ResourceLoader(
            dataLoader: URLSession.shared.data(for:)
        )
    }
    
    @MainActor
    func getFeed() async {
        do {
            feedState = .loading
            
            var resource = try await resourceLoader.loadResource(
                from: DessertFeedEndpoints.getAllDesserts.urlRequest,
                map: DessertFeedItemsMapper.map
            )
            
            resource.sort { $0.name < $1.name }
            feedState = .loaded(resource)
            
        } catch {
            feedState = .error
        }
    }
}
