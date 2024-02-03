//
//  DessertDetailsScreenSnapshotTests.swift
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
final class DessertDetailsScreenSnapshotTests: XCTestCase {
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

extension DessertDetailsScreenSnapshotTests {
    func test_DessertDetailsScreen_BeforeFetchingDetails() {
        let viewModel = DessertDetailsViewModel(mealID: anyMealID)
        let screen = DessertDetailsScreen(viewModel: viewModel)
        let viewController = UIHostingController(rootView: screen)
        
        assertSnapshot(of: viewController, as: .image(on: .iPhone13ProMax))
    }
    
    func test_DessertDetailsScreen_AfterFetchingDetails() async throws {
        let response = try anyValidDessertDetailsResponse()
        
        URLProtocolStub.stub(
            data: response.data,
            response: response.urlResponse,
            error: nil
        )
        
        let viewModel = DessertDetailsViewModel(mealID: anyMealID)
        await viewModel.getDetails()
        
        let screen = DessertDetailsScreen(viewModel: viewModel)
        let viewController = UIHostingController(rootView: screen)
        
        assertSnapshot(of: viewController, as: .image(on: .iPhone13ProMax))
    }
}
