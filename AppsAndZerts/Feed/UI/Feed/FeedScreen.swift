//
//  FeedScreen.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/22/24.
//

import SwiftUI

struct FeedScreen: View {
    @ObservedObject private(set) var viewModel: FeedViewModel
    
    var body: some View {
        NavigationSplitView {
            ZStack {
                Feed(feed: viewModel.feed)
                
                ProgressView()
                    .opacity(viewModel.isLoading ? 1 : 0)
            }
            .navigationTitle(viewModel.navigationTitle)
            
        } detail: {
            Label(viewModel.detail.title, systemImage: viewModel.detail.systemImage)
        }
        .onFirstAppear {
            // Worth noting this doesn't necessarily support cancellation
            Task { await viewModel.getFeed() }
        }
        .alert(viewModel.alertTitle, isPresented: $viewModel.showingAlert) {
            Button("Reload", role: .cancel) {
                Task { await viewModel.getFeed() }
            }
        }
    }
    
    private struct Feed: View {
        let feed: [FeedItem]
        
        var body: some View {
            List(feed, id: \.self) { item in
                NavigationLink {
                    DetailsScreen(
                        viewModel: .init(mealID: item.mealID)
                    )
                    
                } label: {
                    FeedRow(
                        name: item.name,
                        thumbnail: item.thumbnail
                    )
                }
            }
        }
    }
    
    private struct FeedRow: View {
        let name: String
        let thumbnail: URL
        
        var body: some View {
            HStack {
                AsyncImage(url: thumbnail) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 50, height: 50)
                
                Text(name)
                
                Spacer()
            }
        }
    }
}

// FIXME: Would be nice to not hit the endpoint here
#Preview {
    FeedScreen(
        viewModel: .init(resourceType: .appetizer)
    )
}
