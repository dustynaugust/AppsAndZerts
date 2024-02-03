//
//  DessertFeedViewModelTests.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/26/24.
//

import TestHelpers
import XCTest

@testable import AppsAndZerts

final class DessertFeedViewModelTests: XCTestCase {
    private typealias Resource = (Data, HTTPURLResponse)
        
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
extension DessertFeedViewModelTests {
    func test_init_DoesNotLoadDesserts() {
        let sut = DessertFeedViewModel()
        
        XCTAssertTrue(sut.feed.isEmpty)
    }
}

// MARK: - .getFeed() Test(s)
extension DessertFeedViewModelTests {
    func test_getFeed_WhenSuccess() async throws {
        let response = try anyValidDessertFeedResponse()
        
        URLProtocolStub.stub(
            data: response.data,
            response: response.urlResponse,
            error: nil
        )
        
        let sut = DessertFeedViewModel()
        
        await sut.getFeed()
        
        XCTAssertTrue(!sut.feed.isEmpty)
        
        guard 
            case .loaded = sut.feedState
        else {
            XCTFail("Expected \(String(describing: DessertFeedViewModel.FeedState.loaded)) got \(sut.feedState)")
            return
        }
    }
    
    func test_getFeed_WhenError() async throws {
        URLProtocolStub.stub(
            data: nil,
            response: nil,
            error: anyError
        )
        
        let sut = DessertFeedViewModel()
        
        await sut.getFeed()
        
        XCTAssertTrue(sut.feed.isEmpty)
        XCTAssertEqual(sut.feedState, .error)
        XCTAssertTrue(sut.showingAlert)
    }
}
