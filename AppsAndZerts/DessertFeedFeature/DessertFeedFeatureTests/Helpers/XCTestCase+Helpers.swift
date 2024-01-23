//
//  XCTestCase+Helpers.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/22/24.
//

import XCTest

extension XCTestCase {
    func anyNSError() -> NSError {
        NSError(domain: "any-error", code: 1, userInfo: ["user": "info"])
    }
    
    func successfulHTTPURLResponse() throws -> HTTPURLResponse {
        let url = try anyURLRequest().url
        
        return try XCTUnwrap(HTTPURLResponse(url: url,
                                             statusCode: 200,
                                             httpVersion: nil,
                                             headerFields: nil))
    }
    
    func anyURLRequest() throws -> (url: URL, request: URLRequest) {
        let url = try XCTUnwrap(URL(string: "http://any-url.com"))
        let request = URLRequest(url: url)
        
        return (url, request)
    }
    
    func anyURLResponse() throws -> URLResponse {
        let url = try anyURLRequest().url
        
        return URLResponse(url: url,
                           mimeType: nil,
                           expectedContentLength: 1,
                           textEncodingName: nil)
    }
}
