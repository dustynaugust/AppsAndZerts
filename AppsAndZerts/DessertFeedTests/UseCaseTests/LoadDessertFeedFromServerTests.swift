//
//  LoadDessertFeedFromServerTests.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/22/24.
//

import XCTest

@testable import AppsAndZerts

final class LoadDessertFeedFromServerTests: XCTestCase {
    // MARK: - makeSUT
    private func makeSUT(
        result: HTTPClientSpy.Result,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> (sut: DessertFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy(result: result)
        
        let sut = DessertFeedLoader(client: client)
        
        return (sut, client)
    }
    
    // MARK: - Helper(s)
    
    private func anyValidDessertFeedResponse() throws -> HTTPClient.Response {
        let jsonString = """
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
        
        let jsonData = try XCTUnwrap(jsonString.data(using: .utf8))
        let successfulHTTPURLResponse = try any200HTTPURLResponse()
        
        return (jsonData, successfulHTTPURLResponse)
    }
    
    private func makeItem(
        name: String,
        thumbnail: URL,
        mealID: String
    ) -> (model: DessertFeedItem, json: [String: Any]) {
        let item = DessertFeedItem(name: name,
                                   thumbnail: thumbnail,
                                   mealID: mealID)
        
        let json = [
            "strMeal": name,
            "strMealThumb": thumbnail.absoluteString,
            "idMeal": mealID,
        ].compactMapValues { $0 }
        
        return (item, json)
    }
    
    private func makeItemsJSONData(
        _ items: [[String: Any]]
    ) throws -> Data {
        let itemsJSON = ["meals": items]
        return try JSONSerialization.data(withJSONObject: itemsJSON)
    }
    
    
    
    private class HTTPClientSpy: HTTPClient {
        typealias Completion = (HTTPClient.Response) -> Void
        typealias Result = Swift.Result<HTTPClient.Response, Error>
        
        private let result: Result
        private(set) var urlRequests = [URLRequest]()
        
        init(
            result: Result
        ) {
            self.result = result
        }
        
        func makeRequest(
            with request: URLRequest
        ) async throws -> Response {
            urlRequests.append(request)
            
            return try result.get()
        }
    }
}

// MARK: - .init(client:request:) Test(s)
extension LoadDessertFeedFromServerTests {
    func test_init_DoesNotRequestDataFromURL() throws {
        let response = try anyValidDessertFeedResponse()
        let (_, client) = try makeSUT(result: .success(response))
        
        XCTAssertTrue(client.urlRequests.isEmpty)
    }
}

// MARK: - .load() Test(s)
extension LoadDessertFeedFromServerTests {
    func test_load_RequestsDataFromURLRequest() async throws {
        let response = try anyValidDessertFeedResponse()
        let (sut, client) = try makeSUT(result: .success(response))
        
        let _ = try await sut.load()
        
        let expected = [
            DessertFeedEndpoints.getAllDesserts.urlRequest,
        ]
        
        XCTAssertEqual(client.urlRequests, expected)
    }
    
    func test_load_RequestsDataFromURLRequestTwice() async throws {
        let response = try anyValidDessertFeedResponse()
        let (sut, client) = try makeSUT(result: .success(response))
        
        let _ = try await sut.load()
        let _ = try await sut.load()
        
        let expected = [
            DessertFeedEndpoints.getAllDesserts.urlRequest,
            DessertFeedEndpoints.getAllDesserts.urlRequest
        ]
        
        XCTAssertEqual(client.urlRequests, expected)
    }
    
    func test_load_DeliversErrorOnClientError() async throws {
        let (sut, _) = try makeSUT(result: .failure(anyNSError))
        
        await expectErrorThrown(by: try await sut.load())
    }
    
    func test_load_DeliversErrorNon200HTTPResponse() async throws {
        let data = Data(count: 1)
        let url = try XCTUnwrap(anyURLRequest().url)
        let response = try XCTUnwrap(HTTPURLResponse(url: url,
                                                     statusCode: 300,
                                                     httpVersion: nil,
                                                     headerFields: nil))
        
        let (sut, _) = try makeSUT(result: .success((data, response)))
        
        await expect(try await sut.load(), throws: DessertFeedItemsMapper.Error.unexpectedServerResponse)
    }
    
    func test_load_DeliversErrorOn200HTTPResponseWithInvalidJSON() async throws {
        let anyRequest = try anyURLRequest()
        
        let data = try invalidJSONData()
        let response = try any200HTTPURLResponse()
        
        let (sut, _) = try makeSUT(result: .success((data, response)))
        
        await expect(try await sut.load(), throwsErrorOfType: Swift.DecodingError.self)
    }
    
    func test_load_DeliversNoItemsOn200HTTPResponseWithEmptyJSONList() async throws {
        let emptyJSONString = """
        {
            "meals": []
        }
        """
        
        let data = try XCTUnwrap(emptyJSONString.data(using: .utf8))
        let response = try any200HTTPURLResponse()
        
        let (sut, _) = try makeSUT(result: .success((data, response)))
        
        let feedItems = try await sut.load()
        
        XCTAssertTrue(feedItems.isEmpty)
    }
    
    func test_load_DeliversItemsOn200HTTPResponseWithJSONItems() async throws {
        let item1 = makeItem(name: "name-1",
                             thumbnail: URL(string: "http://thumbnail-1.com")!,
                             mealID: "mealID-1")
        let item2 = makeItem(name: "name-2",
                             thumbnail: URL(string: "http://thumbnail-2.com")!,
                             mealID: "mealID-2")
        
        
        let data = try makeItemsJSONData([item1.json, item2.json])
        let response = try any200HTTPURLResponse()
        
        let (sut, _) = try makeSUT(result: .success((data, response)))
        
        let feedItems = try await sut.load()
        
        let expected = [item1.model, item2.model]
        XCTAssertEqual(feedItems, expected)
    }
}
