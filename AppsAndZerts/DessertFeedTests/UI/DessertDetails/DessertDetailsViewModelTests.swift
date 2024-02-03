//
//  DessertDetailsViewModelTests.swift
//  AppsAndZertsTests
//
//  Created by Dustyn August on 1/28/24.
//

import TestHelpers
import XCTest

@testable import AppsAndZerts

final class DessertDetailsViewModelTests: XCTestCase {
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

// MARK: - .init() Test(s)
extension DessertDetailsViewModelTests {
    func test_init_DoesNotLoadDesserts() {
        let sut = DessertDetailsViewModel(mealID: anyMealID)
        
        XCTAssertTrue(sut.isLoading)
        XCTAssertEqual(sut.state, .loading)
    }
}

// MARK: - .getFeed() Test(s)
extension DessertDetailsViewModelTests {
    func test_getFeed_WhenSuccess() async throws {
        let response = try anyValidDessertDetailsResponse()
        
        URLProtocolStub.stub(
            data: response.data,
            response: response.urlResponse,
            error: nil
        )
        
        let sut = DessertDetailsViewModel(mealID: anyMealID)
        
        await sut.getDetails()
        
        guard
            case .loaded = sut.state
        else {
            XCTFail("Expected \(String(describing: DessertDetailsViewModel.State.loaded)) got \(sut.state)")
            return
        }
    }
    
    func test_getFeed_WhenError() async throws {
        URLProtocolStub.stub(
            data: nil,
            response: nil,
            error: anyError
        )
        
        let sut = DessertDetailsViewModel(mealID: anyMealID)
        
        await sut.getDetails()
        
        XCTAssertEqual(sut.state, .error)
        XCTAssertTrue(sut.showingAlert)
    }
}
