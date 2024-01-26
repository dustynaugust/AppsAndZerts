//
//  XCTestCase+Helpers.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/22/24.
//

import XCTest

// MARK: - Generic Helpers

var anyError: Swift.Error { anyNSError }

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

// MARK: - AppsAndZerts Specific Helpers

@testable import AppsAndZerts

func anyValidDessertFeedJSON() -> String {
    """
    {
        "meals": [
            {
                "strMeal": "Apam balik",
                "strMealThumb": "https://www.themealdb.com/images/media/meals/adxcbq1619787919.jpg",
                "idMeal": "53049"
            },
            {
                "strMeal": "Banana Pancakes",
                "strMealThumb": "https://www.themealdb.com/images/media/meals/sywswr1511383814.jpg",
                "idMeal": "52855"
            },
        ]
    }
    """
}

func anyValidDessertFeedResponse() throws -> URLSessionProtocol.Response {
    let jsonData = try XCTUnwrap(anyValidDessertFeedJSON().data(using: .utf8))
    let successfulHTTPURLResponse = try any200HTTPURLResponse()
    
    return (jsonData, successfulHTTPURLResponse)
}
