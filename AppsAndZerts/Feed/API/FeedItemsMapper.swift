//
//  FeedItemsMapper.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/22/24.
//

import Foundation

final class FeedItemsMapper {
    public enum Error: Swift.Error {
        case unexpectedServerResponse
    }
    
    private struct Root: Decodable {
        private let items: [RemoteFeedItem]
        
        enum CodingKeys: String, CodingKey {
            case items = "meals"
        }
        
        var feedItems: [FeedItem] {
            items.map {
                FeedItem(
                    name: $0.strMeal,
                    thumbnail: $0.strMealThumb,
                    mealID: $0.idMeal
                )
            }
        }
    }
    
    private struct RemoteFeedItem: Decodable {
        let strMeal: String
        let strMealThumb: URL
        let idMeal: String
    }
    
    
    private static var OK_200: Int { return 200 }
    
    static func map(
        _ data: Data,
        _ response: HTTPURLResponse
    ) throws -> [FeedItem] {
        guard
            response.statusCode == OK_200
        else {
            throw Error.unexpectedServerResponse
        }
        
        let root = try JSONDecoder().decode(Root.self, from: data)
        
        return root.feedItems
    }
}
