//
//  LoadDessertFeedFromServerTests.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/22/24.
//

import XCTest

@testable import AppsAndZerts

final class LoadDessertFeedFromServerTests: XCTestCase {
    private let loadDessertFeedRequest = FeedEndpoint.getAll(.dessert).urlRequest
    private let mapDataToDessertFeed = FeedItemsMapper.map(_:_:)
    
    
    // MARK: - makeSUT
    private func makeSUT(
        result: HTTPClientSpy.Result,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> (sut: ResourceLoader<[FeedItem]>, client: HTTPClientSpy) {
        let client = HTTPClientSpy(result: result)
        
        let sut = ResourceLoader<[FeedItem]>.init(dataLoader: client.data(for:))
        
        return (sut, client)
    }
    
    // MARK: - Helper(s)
    
    private func makeItem(
        name: String,
        thumbnail: URL,
        mealID: String
    ) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(name: name,
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
}

// MARK: - .init(client:request:) Test(s)
extension LoadDessertFeedFromServerTests {
    func test_init_DoesNotRequestDataFromURL() throws {
        let response = try anyValidFeedResponse()
        let (_, client) = try makeSUT(result: .success(response))
        
        XCTAssertTrue(client.urlRequests.isEmpty)
    }
}

// MARK: - .load() Test(s)
extension LoadDessertFeedFromServerTests {
    func test_load_RequestsDataFromURLRequest() async throws {
        let response = try anyValidFeedResponse()
        let (sut, client) = try makeSUT(result: .success(response))
        
        let _ = try await sut.loadResource(
            from: loadDessertFeedRequest,
            map: mapDataToDessertFeed
        )
        
        let expected = [
            FeedEndpoint.getAll(.dessert).urlRequest,
        ]
        
        XCTAssertEqual(client.urlRequests, expected)
    }
    
    func test_load_RequestsDataFromURLRequestTwice() async throws {
        let response = try anyValidFeedResponse()
        let (sut, client) = try makeSUT(result: .success(response))
        
        let _ = try await sut.loadResource(
            from: loadDessertFeedRequest,
            map: mapDataToDessertFeed
        )
        let _ = try await sut.loadResource(
            from: loadDessertFeedRequest,
            map: mapDataToDessertFeed
        )
        
        let expected = [
            FeedEndpoint.getAll(.dessert).urlRequest,
            FeedEndpoint.getAll(.dessert).urlRequest
        ]
        
        XCTAssertEqual(client.urlRequests, expected)
    }
    
    func test_load_DeliversErrorOnClientError() async throws {
        let (sut, _) = try makeSUT(result: .failure(anyNSError))
        
        await expectErrorThrown(
            by: try await sut.loadResource(
                from: loadDessertFeedRequest,
                map: mapDataToDessertFeed
            )
        )
    }
    
    func test_load_DeliversErrorNon200HTTPResponse() async throws {
        let data = Data(count: 1)
        let url = try XCTUnwrap(anyURLRequest().url)
        let response = try XCTUnwrap(HTTPURLResponse(url: url,
                                                     statusCode: 300,
                                                     httpVersion: nil,
                                                     headerFields: nil))
        
        let (sut, _) = try makeSUT(result: .success((data, response)))
        
        await expect(
            try await sut.loadResource(
                from: loadDessertFeedRequest,
                map: mapDataToDessertFeed
            ),
            throws: FeedItemsMapper.Error.unexpectedServerResponse
        )
    }
    
    func test_load_DeliversErrorOn200HTTPResponseWithInvalidJSON() async throws {
        let data = try invalidJSONData()
        let response = try any200HTTPURLResponse()
        
        let (sut, _) = try makeSUT(result: .success((data, response)))
        
        await expect(
            try await sut.loadResource(
                from: loadDessertFeedRequest,
                map: mapDataToDessertFeed
            ),
            throwsErrorOfType: Swift.DecodingError.self
        )
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
        
        let feedItems = try await sut.loadResource(
            from: loadDessertFeedRequest,
            map: mapDataToDessertFeed
        )
        
        XCTAssertTrue(feedItems.isEmpty)
    }
    
    func test_load_DeliversItemsOn200HTTPResponseWithJSONItems() async throws {
        let item1 = makeItem(
            name: "name-1",
            thumbnail: URL(string: "http://thumbnail-1.com")!,
            mealID: "mealID-1"
        )
        
        let item2 = makeItem(
            name: "name-2",
            thumbnail: URL(string: "http://thumbnail-2.com")!,
            mealID: "mealID-2"
        )
        
        let data = try makeItemsJSONData([item1.json, item2.json])
        let response = try any200HTTPURLResponse()
        
        let (sut, _) = try makeSUT(result: .success((data, response)))
        
        let feedItems = try await sut.loadResource(
            from: loadDessertFeedRequest,
            map: mapDataToDessertFeed
        )
        
        let expected = [item1.model, item2.model]
        XCTAssertEqual(feedItems, expected)
    }
}
