//
//  AppsAndZertsApp.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/22/24.
//

import SwiftUI

@main
struct AppsAndZertsApp: App {
    var body: some Scene {
        WindowGroup {
            DessertFeedScreen(
                viewModel: .init()
            )
        }
    }
}
