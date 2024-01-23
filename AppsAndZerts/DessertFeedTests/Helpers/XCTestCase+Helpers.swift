//
//  XCTestCase+Helpers.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/22/24.
//

import XCTest

/// A generic Error.
var anyError: Swift.Error { anyNSError }

/// A generic NSError.
var anyNSError: NSError { NSError(domain: "any error", code: 0) }

func anyURL() throws -> URL {
    try XCTUnwrap(URL(string: "http://any-url.com"))
}

func anyURLRequest() throws -> URLRequest {
    let url = try anyURL()
    
    return URLRequest(url: url)
}

func anyURLResponse() throws -> URLResponse {
    let url = try anyURL()
    
    return URLResponse(url: url,
                       mimeType: nil,
                       expectedContentLength: 1,
                       textEncodingName: nil)
}

func any200HTTPURLResponse() throws -> HTTPURLResponse {
    let url = try anyURL()
    
    return try XCTUnwrap(HTTPURLResponse(url: url,
                                         statusCode: 200,
                                         httpVersion: nil,
                                         headerFields: nil))
}

func invalidJSONData() throws -> Data {
    try XCTUnwrap("Definitely Not JSON!".data(using: .utf8))
}
