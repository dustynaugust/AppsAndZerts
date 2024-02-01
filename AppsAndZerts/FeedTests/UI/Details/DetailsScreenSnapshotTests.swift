//
//  DetailsScreenSnapshotTests.swift
//  AppsAndZertsTests
//
//  Created by Dustyn August on 1/28/24.
//

import SnapshotTesting
import SwiftUI
import XCTest

@testable import AppsAndZerts

@MainActor
final class DetailsScreenSnapshotTests: XCTestCase {
    private let anyMealID = "any-meal-ID"
    
    override func setUp() {
        super.setUp()
        
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown()  {
        URLProtocolStub.stopInterceptingRequests()
        
        super.tearDown()
    }
}

extension DetailsScreenSnapshotTests {
    func test_DetailsScreen_BeforeFetchingDetails() {
        let viewModel = DetailsViewModel(mealID: anyMealID)
        let screen = DetailsScreen(viewModel: viewModel)
        let viewController = UIHostingController(rootView: screen)
        
        assertSnapshot(of: viewController, as: .image(on: .iPhone13ProMax))
    }
    
    func test_DetailsScreen_AfterFetchingDetails() async throws {
        let response = try anyValidDetailsResponse()
        
        URLProtocolStub.stub(
            data: response.data,
            response: response.urlResponse,
            error: nil
        )
        
        let viewModel = DetailsViewModel(mealID: anyMealID)
        await viewModel.getDetails()
        
        let screen = DetailsScreen(viewModel: viewModel)
        let viewController = UIHostingController(rootView: screen)
        
        assertSnapshot(of: viewController, as: .image(on: .iPhone13ProMax))
    }
}
