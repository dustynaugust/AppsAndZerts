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
        let url = try anyURL()
        
        return try XCTUnwrap(HTTPURLResponse(url: url,
                                             statusCode: 200,
                                             httpVersion: nil,
                                             headerFields: nil))
    }
    
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
}
