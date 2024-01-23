//
//  URLSessionHTTPClientTests.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/22/24.
//

import XCTest
@testable import AppsAndZerts

final class URLSessionHTTPClientTests: XCTestCase {
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
extension URLSessionHTTPClientTests {
    func test_makeRequest_FailsOnError() async {
        URLProtocolStub.stub(data: nil, response: nil, error: anyNSError)
        
        do {
            let request = try anyURLRequest()
            let _ = try await URLSessionHTTPClient().makeRequest(with: request)
            XCTFail("Expected error to be thrown.")
        } catch {
            // Success
        }
    }
    
    func test_makeRequest_ThrowsUnexpectedServerError_WhenUnexpectedResponseRecieved() async throws {
        let response = try anyURLResponse()
        URLProtocolStub.stub(data: nil, response: response, error: nil)
        
        do {
            let request = try anyURLRequest()
            let _ = try await URLSessionHTTPClient().makeRequest(with: request)
            XCTFail("Expected error to be thrown.")
        } catch {
            XCTAssertEqual(error as? URLSessionHTTPClient.Error, .unexpectedServerError)
        }
    }
    
    func test_makeRequest_ReturnsExpectedHTTPURLResponse() async throws {
        let expected = try any200HTTPURLResponse()
        URLProtocolStub.stub(data: nil, response: expected, error: nil)
        
        let request = try anyURLRequest()
        let (_, actual) = try await URLSessionHTTPClient().makeRequest(with: request)
        
        XCTAssertEqual(actual.statusCode, expected.statusCode)
        XCTAssertEqual(actual.url, expected.url)
    }
    
    func test_makeRequest_ReturnsExpectedData() async throws {
        let response = try any200HTTPURLResponse()
        let expected = Data(count: 666)
        
        URLProtocolStub.stub(data: expected, response: response, error: nil)
        
        let request = try anyURLRequest()
        let (actual, _) = try await URLSessionHTTPClient().makeRequest(with: request)
        
        XCTAssertEqual(actual, expected)
    }
}
