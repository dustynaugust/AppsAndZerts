//
//  DessertFeed.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/22/24.
//

import SwiftUI

class DessertFeedViewModel: ObservableObject {
    typealias Feed = [DessertFeedItem]
    
    @Published private(set) var feed: Feed
    
    var isLoading: Bool { feed.isEmpty }
    
    private let resourceLoader: ResourceLoader<Feed>
    
    init() {
        feed = []
        
        resourceLoader = ResourceLoader(
            dataLoader: URLSession.shared.data(for:)
        )
    }
    
    @MainActor
    func getFeed() async throws {
        var resource = try await resourceLoader.loadResource(
            from: DessertFeedEndpoints.getAllDesserts.urlRequest,
            map: DessertFeedItemsMapper.map
        )
        
        resource.sort { $0.name < $1.name }
        
        feed = resource
    }
}

struct DessertFeedView: View {
    @ObservedObject private(set) var viewModel: DessertFeedViewModel
    
    var body: some View {
        
        ZStack {
            Section {
                List(viewModel.feed, id: \.self) { item in
                    VStack {
                        Text(item.name)
                        Text(item.mealID)
                        Text(item.thumbnail.absoluteString)
                    }
                }
            } header: {
                Text("Desserts")
            }
            .onFirstAppear {
                // Worth noting this doesn't necessarily support cancellation
                Task { try? await viewModel.getFeed() }
            }
            
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : 0)
        }
    }
}

// FIXME: Would be nice to not hit the endpoint here
#Preview {
    DessertFeedView(
        viewModel: .init()
    )
}