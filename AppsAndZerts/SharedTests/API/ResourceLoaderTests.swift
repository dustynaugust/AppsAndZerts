//
//  ResourceLoaderTests.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/22/24.
//

import XCTest

@testable import AppsAndZerts

final class ResourceLoaderTests: XCTestCase {
    private typealias Resource = (Data, HTTPURLResponse)
    
    private let resourceLoader = ResourceLoader<Resource>(dataLoader: URLSession.shared.data(for:))
    private let mapToTuple: (Data, HTTPURLResponse) throws -> (Data, HTTPURLResponse) = { ($0, $1) }
    
    override func setUp() {
        super.setUp()
        
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown()  {
        URLProtocolStub.stopInterceptingRequests()
        
        super.tearDown()
    }
}

// MARK: - .makeRequest() Test(s)
extension ResourceLoaderTests {
    func test_loadResource_FailsOnError() async throws {
        URLProtocolStub.stub(data: nil, response: try any200HTTPURLResponse(), error: anyNSError)
        
        let request = try anyURLRequest()
        
        await expectErrorThrown(
            by: try await resourceLoader.loadResource(
                from: request,
                map: mapToTuple
            )
        )
    }
    
    func test_loadResource_ThrowsUnexpectedServerError_WhenUnexpectedResponseRecieved() async throws {
        let nonHTTPURL = try XCTUnwrap(URL(string: "not-http://any-url.com"))
        
        let nonHTTPURLResponse = URLResponse(url: nonHTTPURL,
                                             mimeType: nil,
                                             expectedContentLength: 1,
                                             textEncodingName: nil)

        URLProtocolStub.stub(data: nil, response: nonHTTPURLResponse, error: nil)
        
        let anyURLRequest = try anyURLRequest()
        
        await expect(
            try await resourceLoader.loadResource(
                from: anyURLRequest,
                map: mapToTuple
            ),
            throws: ResourceLoader<Resource>.Error.unexpectedServerResponse
        )
    }
    
    func test_loadResource_ReturnsExpectedHTTPURLResponse() async throws {
        let expected = try any200HTTPURLResponse()
        URLProtocolStub.stub(data: nil, response: expected, error: nil)
        
        let (_, actual) = try await resourceLoader.loadResource(from: anyURLRequest(),
                                                                map: mapToTuple)
        
        XCTAssertEqual(actual.statusCode, expected.statusCode)
        XCTAssertEqual(actual.url, expected.url)
    }
    
    func test_loadResource_ReturnsExpectedData() async throws {
        let response = try any200HTTPURLResponse()
        let expected = Data(count: 666)
        
        URLProtocolStub.stub(data: expected, response: response, error: nil)
        
        let (actual, _) = try await resourceLoader.loadResource(from: anyURLRequest(),
                                                                map: mapToTuple)
        
        XCTAssertEqual(actual, expected)
    }
}
