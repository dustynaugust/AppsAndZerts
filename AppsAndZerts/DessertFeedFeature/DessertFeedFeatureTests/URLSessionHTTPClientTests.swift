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
        let error = NSError(domain: "any-error", code: 1, userInfo: ["user": "info"])
        URLProtocolStub.stub(data: nil, response: nil, error: error)
        
        do {
            let _ = try await URLSessionHTTPClient.makeRequest()
            XCTFail("Expected error to be thrown.")
        } catch {
            // Success
        }
    }
    
    func test_makeRequest_ThrowsUnexpectedServerError_WhenUnexpectedResponseRecieved() async {
        let url = URL(string: "http://any-url.com")!
        let response = URLResponse(url: url,
                                   mimeType: nil,
                                   expectedContentLength: 1,
                                   textEncodingName: nil)
        URLProtocolStub.stub(data: nil, response: response, error: nil)
        
        do {
            let _ = try await URLSessionHTTPClient.makeRequest()
            XCTFail("Expected error to be thrown.")
        } catch {
            XCTAssertEqual(error as? URLSessionHTTPClient.Error, .unexpectedServerError)
        }
    }
    
    func test_makeRequest_ReturnsExpectedHTTPURLResponse() async throws {
        let url = URL(string: "http://any-url.com")!
        let expectedResponse = HTTPURLResponse(url: url,
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: nil)
        URLProtocolStub.stub(data: nil, response: expectedResponse, error: nil)
        
        let (_, actualResponse) = try await URLSessionHTTPClient.makeRequest()
        
        let expectedStatusCode = try XCTUnwrap(expectedResponse?.statusCode)
        XCTAssertEqual(actualResponse.statusCode, expectedStatusCode)
        
        let expectedURL = try XCTUnwrap(expectedResponse?.url)
        XCTAssertEqual(actualResponse.url, expectedURL)
    }
    
    func test_makeRequest_ReturnsExpectedData() async throws {
        let url = URL(string: "http://any-url.com")!
        let response = HTTPURLResponse(url: url,
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: nil)
        let expectedData = Data(count: 666)
        
        URLProtocolStub.stub(data: expectedData, response: response, error: nil)
        
        let (actualData, _) = try await URLSessionHTTPClient.makeRequest()
        
        XCTAssertEqual(actualData, expectedData)
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
