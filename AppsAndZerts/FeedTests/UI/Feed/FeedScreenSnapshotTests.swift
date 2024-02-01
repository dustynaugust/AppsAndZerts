//
//  FeedScreenSnapshotTests.swift
//  AppsAndZertsTests
//
//  Created by Dustyn August on 1/28/24.
//

import SnapshotTesting
import SwiftUI
import XCTest

@testable import AppsAndZerts

@MainActor
final class FeedScreenSnapshotTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown()  {
        URLProtocolStub.stopInterceptingRequests()
        
        super.tearDown()
    }
}

extension FeedScreenSnapshotTests {
    func test_FeedScreen_Desserts_BeforeFetchingFeed() async throws {
        let response = try anyValidFeedResponse()
        
        URLProtocolStub.stub(
            data: response.data,
            response: response.urlResponse,
            error: nil
        )
        
        let viewModel = FeedViewModel(resourceType: .dessert)
        let screen = FeedScreen(viewModel: viewModel)
        let viewController = UIHostingController(rootView: screen)
        
        assertSnapshot(of: viewController, as: .image(on: .iPhone13ProMax))
    }
    
    func test_FeedScreen_Appetizers_BeforeFetchingFeed() async throws {
        let response = try anyValidFeedResponse()
        
        URLProtocolStub.stub(
            data: response.data,
            response: response.urlResponse,
            error: nil
        )
        
        let viewModel = FeedViewModel(resourceType: .appetizer)
        let screen = FeedScreen(viewModel: viewModel)
        let viewController = UIHostingController(rootView: screen)
        
        assertSnapshot(of: viewController, as: .image(on: .iPhone13ProMax))
    }
    
    func test_FeedScreen_Desserts_AfterFetchingFeed() async throws {
        let response = try anyValidFeedResponse()
        
        URLProtocolStub.stub(
            data: response.data,
            response: response.urlResponse,
            error: nil
        )
        
        let viewModel = FeedViewModel(resourceType: .dessert)
        await viewModel.getFeed()
        
        let screen = FeedScreen(viewModel: viewModel)
        let viewController = UIHostingController(rootView: screen)
        
        assertSnapshot(of: viewController, as: .image(on: .iPhone13ProMax))
    }
    
    func test_FeedScreen_Appetizers_AfterFetchingFeed() async throws {
        let response = try anyValidFeedResponse()
        
        URLProtocolStub.stub(
            data: response.data,
            response: response.urlResponse,
            error: nil
        )
        
        let viewModel = FeedViewModel(resourceType: .appetizer)
        await viewModel.getFeed()
        
        let screen = FeedScreen(viewModel: viewModel)
        let viewController = UIHostingController(rootView: screen)
        
        assertSnapshot(of: viewController, as: .image(on: .iPhone13ProMax))
    }
}
