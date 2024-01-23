//
//  LoadDessertFeedFromServerTests.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/22/24.
//

import XCTest
@testable import AppsAndZerts

final class LoadDessertFeedFromServerTests: XCTestCase {
    
    // MARK: - Helper(s)
    
    private func makeSUT(
        request: URLRequest,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> (sut: DessertFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy(data: Data(count: 666),
                                   httpURLResponse: try successfulHTTPURLResponse())
        
        let sut = DessertFeedLoader(client: client,
                                    request: request)
        
        return (sut, client)
    }
    
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

// MARK: - .init(client:request:) Test(s)
extension LoadDessertFeedFromServerTests {
    func test_init_DoesNotRequestDataFromURL() throws {
        let anyRequest = try anyURLRequest()
        let (_, client) = try makeSUT(request: anyRequest)
        
        XCTAssertTrue(client.urlRequests.isEmpty)
    }
}

// MARK: - .load() Test(s)
extension LoadDessertFeedFromServerTests {
    func test_load_RequestsDataFromURLRequest() async throws {
        let anyRequest = try anyURLRequest()
        let (sut, client) = try makeSUT(request: anyRequest)
        
        try await sut.load()
        
        XCTAssertEqual(client.urlRequests, [anyRequest])
    }
    
    func test_load_RequestsDataFromURLRequestTwice() async throws {
        let anyRequest = try anyURLRequest()
        let (sut, client) = try makeSUT(request: anyRequest)
        
        try await sut.load()
        try await sut.load()
        
        XCTAssertEqual(client.urlRequests, [anyRequest, anyRequest])
    }
}
