//
//  DessertFeed.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/22/24.
//

import SwiftUI

struct DessertFeedScreen: View {
    @ObservedObject private(set) var viewModel: DessertFeedViewModel
    
    var body: some View {
        NavigationSplitView {
            ZStack {
                DessertFeed(feed: viewModel.feed)
                
                ProgressView()
                    .opacity(viewModel.isLoading ? 1 : 0)
            }
            .navigationTitle("Desserts")
            
        } detail: {
            Label("Woo, Desserts!", systemImage: "birthday.cake")
        }
        .onFirstAppear {
            // Worth noting this doesn't necessarily support cancellation
            Task { await viewModel.getFeed() }
        }
        .alert("Failed to retrieve desserts", isPresented: $viewModel.showingAlert) {
            Button("Reload", role: .cancel) {
                Task { await viewModel.getFeed() }
            }
        }
    }
    
    private struct DessertFeed: View {
        let feed: [DessertFeedItem]
        
        var body: some View {
            List(feed, id: \.self) { item in
                NavigationLink {
                    DessertDetailsScreen(
                        viewModel: .init(mealID: item.mealID)
                    )
                    
                } label: {
                    HStack {
                        Text(item.name)
                        
                        Spacer()
                    }
                }
            }
        }
    }
}

// FIXME: Would be nice to not hit the endpoint here
//#Preview {
//    DessertFeedScreen(
//        viewModel: .init()
//    )
//}
