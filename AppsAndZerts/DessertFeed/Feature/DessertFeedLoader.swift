//
//  DessertFeedLoader.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/22/24.
//

import Foundation

struct DessertFeedLoader {
    public enum Error: Swift.Error {
        case unexpectedServerResponse
        case random
    }
    
    private let client: HTTPClient
    private let request: URLRequest
    
    init(
        client: HTTPClient = URLSessionHTTPClient()
    ) {
        self.client = client
        self.request = DessertFeedEndpoints.getAllDesserts.urlRequest
    }
    
    func load() async throws -> [DessertFeedItem] {
        let (data, response) = try await client.makeRequest(with: request)
        
        return try DessertFeedItemsMapper.map(data, response)
    }
}
