//
//  URLSessionHTTPClientTests.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/22/24.
//

import XCTest

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
        URLProtocolStub.stub(data: nil, response: nil, error: anyNSError())
        
        do {
            let _ = try await URLSessionHTTPClient.makeRequest()
            XCTFail("Expected error to be thrown.")
        } catch {
            // Success
        }
    }
    
    func test_makeRequest_ThrowsUnexpectedServerError_WhenUnexpectedResponseRecieved() async throws {
        let response = try anyURLResponse()
        URLProtocolStub.stub(data: nil, response: response, error: nil)
        
        do {
            let _ = try await URLSessionHTTPClient.makeRequest()
            XCTFail("Expected error to be thrown.")
        } catch {
            XCTAssertEqual(error as? URLSessionHTTPClient.Error, .unexpectedServerError)
        }
    }
    
    func test_makeRequest_ReturnsExpectedHTTPURLResponse() async throws {
        let expected = try successfulHTTPURLResponse()
        URLProtocolStub.stub(data: nil, response: expected, error: nil)
        
        let (_, actual) = try await URLSessionHTTPClient.makeRequest()
        
        XCTAssertEqual(actual.statusCode, expected.statusCode)
        XCTAssertEqual(actual.url, expected.url)
    }
    
    func test_makeRequest_ReturnsExpectedData() async throws {
        let response = try successfulHTTPURLResponse()
        let expected = Data(count: 666)
        
        URLProtocolStub.stub(data: expected, response: response, error: nil)
        
        let (actual, _) = try await URLSessionHTTPClient.makeRequest()
        
        XCTAssertEqual(actual, expected)
    }
}



enum URLSessionHTTPClient {
    enum Error: Swift.Error {
        case unexpectedServerError
    }
        
    static func makeRequest() async throws -> (data: Data, httpURLResponse: HTTPURLResponse) {
        let url = URL(string: "http://any-url.com")!
        let request = URLRequest(url: url)
        
        let (data, urlResponse) = try await URLSession.shared.data(for: request)
        
        guard
            let httpURLResponse = urlResponse as? HTTPURLResponse
        else {
            throw Error.unexpectedServerError
        }
        
        return (data, httpURLResponse)
    }
}

class URLProtocolStub: URLProtocol {
    static var session: URLSession?
    private static var stub: Stub?
    
    private struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }
    
    static func stub(data: Data?,
                     response: URLResponse?,
                     error: Error?) {
        stub = Stub(data: data, response: response, error: error)
        
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [URLProtocolStub.self]
        session = URLSession(configuration: configuration)
    }
    
    static func startInterceptingRequests() {
        URLProtocol.registerClass(URLProtocolStub.self)
    }
    
    static func stopInterceptingRequests() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
        stub = nil
        session = nil
    }
   
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        if let data = URLProtocolStub.stub?.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = URLProtocolStub.stub?.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let error = URLProtocolStub.stub?.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() { }
}
