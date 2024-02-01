//
//  FeedEndpoint.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/22/24.
//

import Foundation

enum ResourceType {
    case dessert
    case appetizer
    
    var queryValue: String {
        switch self {
        case .dessert:
            return "Dessert"
            
        case .appetizer:
            return "Starter"
        }
    }
}
enum FeedEndpoint {
    case getAll(ResourceType)
    case get(mealID: String)
    
    private var baseURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "themealdb.com"
        components.path = "/api/json/v1/1"
        
        return components.url!
    }
    
    var urlRequest: URLRequest {
        var components = URLComponents()
        components.scheme = baseURL.scheme
        components.host = baseURL.host
        
        switch self {
        case let .getAll(resourceType):
            components.path = baseURL.path + "/filter.php"
            components.queryItems = [URLQueryItem(name: "c", value: resourceType.queryValue)]
        
        case let .get(mealID):
            components.path = baseURL.path + "/lookup.php"
            components.queryItems = [URLQueryItem(name: "i", value: "\(mealID)")]
        }
        
        return URLRequest(url: components.url!)
    }
}
