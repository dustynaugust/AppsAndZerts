//
//  LoadDessertDetailsFromServerTests.swift
//  AppsAndZertsTests
//
//  Created by Dustyn August on 1/26/24.
//

import XCTest

@testable import AppsAndZerts

final class LoadDessertDetailsFromServerTests: XCTestCase {
    private let loadDessertDetailsEndpoint = DessertFeedEndpoints.get(mealID: "any_ID")
    private var loadDessertDetailsRequest: URLRequest { loadDessertDetailsEndpoint.urlRequest }
    private let mapDataToDessertDetailsItem = DessertDetailsItemMapper.map(_:_:)
    
    // MARK: - makeSUT
    private func makeSUT(
        result: HTTPClientSpy.Result,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> (sut: ResourceLoader<DessertDetailsItem>, client: HTTPClientSpy) {
        let client = HTTPClientSpy(result: result)
        
        let sut = ResourceLoader<DessertDetailsItem>.init(dataLoader: client.data(for:))
        
        return (sut, client)
    }
    
    private func makeItem(
        area: String,
        category: String,
        creativeCommonsConfirmed: String?,
        dateModified: String?,
        drinkAlternate: String?,
        imageSource: String?,
        ingredients: [Ingredient],
        instructions: String,
        mealID: String,
        name: String,
        source: URL,
        tags: String?,
        thumbnailURL: URL,
        youtubeURL: URL
    ) -> (model: DessertDetailsItem, json: [String: Any]) {
        let item = DessertDetailsItem(
            area: area,
            category: category,
            creativeCommonsConfirmed: creativeCommonsConfirmed,
            dateModified: dateModified,
            drinkAlternate: drinkAlternate,
            imageSource: imageSource,
            ingredients: ingredients,
            instructions: instructions,
            mealID: mealID,
            name: name,
            source: source,
            tags: tags,
            thumbnailURL: thumbnailURL,
            youtubeURL: youtubeURL
        )
            
        var json = [
            "idMeal": item.mealID,
            "strMeal": item.name,
            "strDrinkAlternate": item.drinkAlternate ?? "null",
            "strCategory": item.category,
            "strArea": item.area,
            "strInstructions": item.instructions,
            "strMealThumb": item.thumbnailURL?.absoluteString ?? "null",
            "strTags": item.tags ?? "null",
            "strYoutube": item.youtubeURL?.absoluteString ?? "null",
            "strSource": item.source?.absoluteString ?? "null",
            "strImageSource": item.imageSource,
            "strCreativeCommonsConfirmed": item.creativeCommonsConfirmed,
            "dateModified": item.dateModified
        ]
        
        for (index, ingredient) in ingredients.enumerated() {
            json["strIngredient\(index + 1)"] = ingredient.name
            json["strMeasure\(index + 1)"] = ingredient.measurement
        }
        
        return (item, json.compactMapValues { $0 })
    }
    
    private func makeItemsJSONData(
        _ items: [[String: Any]]
    ) throws -> Data {
        let itemsJSON = ["meals": items]
        return try JSONSerialization.data(withJSONObject: itemsJSON)
    }
}


// MARK: - .init(client:request:) Test(s)
extension LoadDessertDetailsFromServerTests {
    func test_init_DoesNotRequestDataFromURL() throws {
        let response = try anyValidDessertDetailsResponse()
        let (_, client) = try makeSUT(result: .success(response))
        
        XCTAssertTrue(client.urlRequests.isEmpty)
    }
}

// MARK: - .load() Test(s)
extension LoadDessertDetailsFromServerTests {
    func test_load_RequestsDataFromURLRequest() async throws {
        let response = try anyValidDessertDetailsResponse()
        let (sut, client) = try makeSUT(result: .success(response))
        
        let _ = try await sut.loadResource(
            from: loadDessertDetailsRequest,
            map: mapDataToDessertDetailsItem
        )
        
        let expected = [
            loadDessertDetailsRequest,
        ]
        
        XCTAssertEqual(client.urlRequests, expected)
    }
    
    func test_load_RequestsDataFromURLRequestTwice() async throws {
        let response = try anyValidDessertDetailsResponse()
        let (sut, client) = try makeSUT(result: .success(response))
        
        let _ = try await sut.loadResource(
            from: loadDessertDetailsRequest,
            map: mapDataToDessertDetailsItem
        )
        
        let _ = try await sut.loadResource(
            from: loadDessertDetailsRequest,
            map: mapDataToDessertDetailsItem
        )
        
        let expected = [
            loadDessertDetailsRequest,
            loadDessertDetailsRequest,
        ]
        
        XCTAssertEqual(client.urlRequests, expected)
    }
    
    func test_load_DeliversErrorOnClientError() async throws {
        let (sut, _) = try makeSUT(result: .failure(anyNSError))
        
        await expectErrorThrown(
            by: try await sut.loadResource(
                from: loadDessertDetailsRequest,
                map: mapDataToDessertDetailsItem
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
                from: loadDessertDetailsRequest,
                map: mapDataToDessertDetailsItem
            ),
            throws: DessertDetailsItemMapper.Error.unexpectedServerResponse
        )
    }
    
    func test_load_DeliversErrorOn200HTTPResponseWithInvalidJSON() async throws {
        let data = try invalidJSONData()
        let response = try any200HTTPURLResponse()
        
        let (sut, _) = try makeSUT(result: .success((data, response)))
        
        await expect(
            try await sut.loadResource(
                from: loadDessertDetailsRequest,
                map: mapDataToDessertDetailsItem
            ),
            throwsErrorOfType: Swift.DecodingError.self
        )
    }
    
    func test_load_DeliversErrorOn200HTTPResponseWithEmptyJSONList() async throws {
        let emptyJSONString = """
        {
            "meals": []
        }
        """
        
        let data = try XCTUnwrap(emptyJSONString.data(using: .utf8))
        let response = try any200HTTPURLResponse()
        
        let (sut, _) = try makeSUT(result: .success((data, response)))
        
        await expect(
            try await sut.loadResource(
                from: loadDessertDetailsRequest,
                map: mapDataToDessertDetailsItem
            ),
            throws: DessertDetailsItemMapper.Error.emptyServerResponse
        )
    }
    
    func test_load_DeliversItemsOn200HTTPResponseWithJSONItems() async throws {
        let item1 = makeItem(
            area: "area-1",
            category: "category-1",
            creativeCommonsConfirmed: "creativeCommonsConfirmed-1",
            dateModified: "dateModified-1",
            drinkAlternate: "drinkAlternate-1",
            imageSource: "imageSource-1",
            ingredients: [
                Ingredient(name: "ingredient1-1", measurement: "measurement1-1"),
                Ingredient(name: "ingredient1-2", measurement: "measurement1-2"),
                Ingredient(name: "ingredient1-3", measurement: "measurement1-3")
            ],
            instructions: "instructions-1",
            mealID: "mealID-1",
            name: "name-1",
            source: URL(string: "http://source-1.com")!,
            tags: "tags-1",
            thumbnailURL: URL(string: "http://thumbnail-1.com")!,
            youtubeURL: URL(string: "http://youtube-1.com")!
        )
        
        let item2 = makeItem(
            area: "area-2",
            category: "category-2",
            creativeCommonsConfirmed: "creativeCommonsConfirmed-2",
            dateModified: "dateModified-2",
            drinkAlternate: "drinkAlternate-2",
            imageSource: "imageSource-2",
            ingredients: [
                Ingredient(name: "ingredient2-1", measurement: "measurement2-1"),
                Ingredient(name: "ingredient2-2", measurement: "measurement2-2"),
                Ingredient(name: "ingredient2-3", measurement: "measurement2-3")
            ],
            instructions: "instructions-2",
            mealID: "mealID-2",
            name: "name-2",
            source: URL(string: "http://source-2.com")!,
            tags: "tags-2",
            thumbnailURL: URL(string: "http://thumbnail-2.com")!,
            youtubeURL: URL(string: "http://youtube-2.com")!
        )
        
        let data = try makeItemsJSONData([item1.json, item2.json])
        let response = try any200HTTPURLResponse()
        
        let (sut, _) = try makeSUT(result: .success((data, response)))
        
        let detailItem = try await sut.loadResource(
            from: loadDessertDetailsRequest,
            map: mapDataToDessertDetailsItem
        )
        
        XCTAssertEqual(detailItem, item1.model)
    }
}
