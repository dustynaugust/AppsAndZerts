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
        Section {
            ZStack {
                
                List(viewModel.feed, id: \.self) { item in
                    VStack {
                        Text(item.name)
                        Text(item.mealID)
                        Text(item.thumbnail.absoluteString)
                    }
                }
                
                ProgressView()
                    .opacity(viewModel.isLoading ? 1 : 0)
            }
        } header: {
            Label("Desserts", systemImage: "birthday.cake")
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
}

// FIXME: Would be nice to not hit the endpoint here
//#Preview {
//    DessertFeedScreen(
//        viewModel: .init()
//    )
//}
