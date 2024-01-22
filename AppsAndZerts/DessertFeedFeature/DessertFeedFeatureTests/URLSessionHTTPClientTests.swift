//
//  URLSessionHTTPClientTests.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/22/24.
//

import XCTest

struct URLSessionHTTPClient {
    func makeRequest() throws {
        throw NSError()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    func test_makeRequest_FailsOnError() {
        let sut = URLSessionHTTPClient()
        
        XCTAssertThrowsError(try sut.makeRequest())
    }
}
