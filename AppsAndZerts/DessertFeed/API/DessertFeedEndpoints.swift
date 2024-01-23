//
//  DessertFeedEndpoints.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/22/24.
//

import Foundation

enum DessertFeedEndpoints {
    case getAllDesserts
    case get(mealID: String)
    
    var url: URL {
        var components = URLComponents()
        components.scheme = baseURL.scheme
        components.host = baseURL.host
        
        switch self {
        case .getAllDesserts:
            components.path = baseURL.path + "filter.php?c=Dessert"
        
        case let .get(mealID):
            components.path = baseURL.path + "lookup.php?i=\(mealID)"
        }
        
        
        return components.url!
    }
    
    private var baseURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "themealdb.com"
        components.path = "api/json/v1/1"
        
        return components.url!
    }
    
}
