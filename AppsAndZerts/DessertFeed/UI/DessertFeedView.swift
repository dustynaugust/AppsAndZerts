//
//  DessertFeed.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/22/24.
//

import SwiftUI

class DessertFeedViewModel: ObservableObject {
    @Published private(set) var desserts: [DessertFeedItem]
    
    init() {
        desserts = []
    }
    
    @MainActor
    func getFeed() async throws {
        var result = try await DessertFeedLoader().load()
        result.sort { $0.name < $1.name }
        
        desserts = result
    }
}

struct DessertFeedView: View {
    @ObservedObject private(set) var viewModel: DessertFeedViewModel
    
    var body: some View {
        Section {
            List(viewModel.desserts, id: \.self) { dessert in
                
                VStack {
                    Text(dessert.name)
                    Text(dessert.mealID)
                    Text(dessert.thumbnail.absoluteString)
                }
            }
        } header: {
            Text("Desserts")
        }
        .onFirstAppear {
            Task { try? await viewModel.getFeed() }
        }
    }
}

// FIXME: Would be nice to not hit the endpoint here
#Preview {
    DessertFeedView(
        viewModel: .init()
    )
}



struct ViewFirstAppearModifier: ViewModifier {
    ///State keeps it's value when view is changed
    @State private var didAppear = false
    private let action: (() -> Void)
    
    init(perform action: @escaping (() -> Void)) {
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content.onAppear {
            guard !didAppear else { return }
            
            didAppear = true
            action()
        }
    }
}

extension View {
    func onFirstAppear(perform action: @escaping (() -> Void)) -> some View {
        modifier(ViewFirstAppearModifier(perform: action))
    }
}
