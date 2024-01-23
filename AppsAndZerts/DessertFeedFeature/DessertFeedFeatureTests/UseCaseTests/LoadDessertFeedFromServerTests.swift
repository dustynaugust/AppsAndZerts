//
//  LoadDessertFeedFromServerTests.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/22/24.
//

import XCTest
@testable import AppsAndZerts

final class LoadDessertFeedFromServerTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() throws {
        let anyRequest = try anyURLRequest()
        let client = HTTPClientSpy(data: Data(count: 666),
                                   httpURLResponse: try successfulHTTPURLResponse())
        let _ = DessertFeedLoader(client: client,
                                    request: anyRequest)
        
        XCTAssertTrue(client.urlRequests.isEmpty)
    }
    
    func test_load_requestsDataFromURLRequest() async throws {
        let anyRequest = try anyURLRequest()
        let client = HTTPClientSpy(data: Data(count: 666),
                                   httpURLResponse: try successfulHTTPURLResponse())
        
        let sut = DessertFeedLoader(client: client,
                                    request: anyRequest)
        
        try await sut.load()
        
        XCTAssertEqual(client.urlRequests, [anyRequest])
    }
    
    func test_load_requestsDataFromURLRequestTwice() async throws {
        let anyRequest = try anyURLRequest()
        let client = HTTPClientSpy(data: Data(count: 666),
                                   httpURLResponse: try successfulHTTPURLResponse())
        
        let sut = DessertFeedLoader(client: client,
                                    request: anyRequest)
        
        try await sut.load()
        try await sut.load()
        
        XCTAssertEqual(client.urlRequests, [anyRequest, anyRequest])
    }
    
    // MARK: - Helper(s)
    
    private struct DessertFeedLoader {
        private let client: HTTPClient
        private let request: URLRequest
        
        init(
            client: HTTPClient,
            request: URLRequest
        ) {
            self.client = client
            self.request = request
        }
        
        func load() async throws {
            let (_, _) = try await client.makeRequest(with: request)
        }
    }
    
    private class HTTPClientSpy: HTTPClient {
        typealias Response = (data: Data, httpURLResponse: HTTPURLResponse)
        
        private let response: Response
        private(set) var urlRequests = [URLRequest]()
        
        init(
            data: Data,
            httpURLResponse: HTTPURLResponse
        ) {
            self.response = (data, httpURLResponse)
        }
        
        
        func makeRequest(
            with request: URLRequest
        ) async throws -> Response {
            urlRequests.append(request)
            
            return response
        }
        
        
    }
}

