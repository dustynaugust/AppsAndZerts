//
//  DessertFeed.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/22/24.
//

import SwiftUI

class DessertFeedViewModel: ObservableObject {
    
}

struct DessertFeedView: View {
    @ObservedObject private(set) var viewModel: DessertFeedViewModel
    
    var body: some View {
        Text("Desert Feed Placeholder")
    }
}

#Preview {
    DessertFeedView(
        viewModel: .init()
    )
}
