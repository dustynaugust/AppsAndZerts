//
//  DessertFeedScreenSnapshotTests.swift
//  AppsAndZertsTests
//
//  Created by Dustyn August on 1/28/24.
//

import SnapshotTesting
import SwiftUI
import TestHelpers
import XCTest

@testable import AppsAndZerts

@MainActor
final class DessertFeedScreenSnapshotTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown()  {
        URLProtocolStub.stopInterceptingRequests()
        
        super.tearDown()
    }
}

extension DessertFeedScreenSnapshotTests {
    func test_DessertFeedScreen_BeforeFetchingFeed() async throws {
        let response = try anyValidDessertFeedResponse()
        
        URLProtocolStub.stub(
            data: response.data,
            response: response.urlResponse,
            error: nil
        )
        
        let viewModel = DessertFeedViewModel()
        let screen = DessertFeedScreen(viewModel: viewModel)
        let viewController = UIHostingController(rootView: screen)
        
        assertSnapshot(of: viewController, as: .image(on: .iPhone13ProMax))
    }
    
    func test_DessertFeedScreen_AfterFetchingFeed() async throws {
        let response = try anyValidDessertFeedResponse()
        
        URLProtocolStub.stub(
            data: response.data,
            response: response.urlResponse,
            error: nil
        )
        
        let viewModel = DessertFeedViewModel()
        await viewModel.getFeed()
        
        let screen = DessertFeedScreen(viewModel: viewModel)
        let viewController = UIHostingController(rootView: screen)
        
        assertSnapshot(of: viewController, as: .image(on: .iPhone13ProMax))
    }
}
