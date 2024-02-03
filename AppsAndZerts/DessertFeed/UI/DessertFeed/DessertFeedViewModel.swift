//
//  DessertFeedViewModel.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/24/24.
//

import Foundation
import HTTPService

class DessertFeedViewModel: ObservableObject {
    typealias Feed = [DessertFeedItem]
    
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
    
    init() {
        feedState = .loading
        
        httpService = URLSessionHTTPService(
            for: DessertFeedEndpoints.getAllDesserts.urlRequest,
            map: DessertFeedItemsMapper.map
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
