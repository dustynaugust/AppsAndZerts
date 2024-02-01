//
//  MainView.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/31/24.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            FeedScreen(
                viewModel: .init(resourceType: .appetizer)
            )
            .tabItem {
                Label("Apps", systemImage: "fork.knife")
            }
            
            FeedScreen(
                viewModel: .init(resourceType: .dessert)
            )
            .tabItem {
                Label("'Zerts", systemImage: "birthday.cake")
            }
        }
    }
}

#Preview {
    MainView()
}

