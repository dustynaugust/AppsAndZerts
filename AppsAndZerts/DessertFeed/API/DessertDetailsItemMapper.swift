//
//  DessertDetailsItemMapper.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/27/24.
//

import Foundation

final class DessertDetailsItemMapper {
    public enum Error: Swift.Error {
        case unexpectedServerResponse
        case emptyServerResponse
    }
    
    private struct Root: Decodable {
        private let items: [RemoteDetailsItem]
        
        enum CodingKeys: String, CodingKey {
            case items = "meals"
        }
        
        var dessertDetailsItems: [DessertDetailsItem] {
            items.map {
                let ingredients = zip($0.strIngredients, $0.strMeasurements)
                    .map { Ingredient(name: $0.0, measurement: $0.1) }
                
                return DessertDetailsItem(
                    area: $0.strArea,
                    category: $0.strCategory,
                    creativeCommonsConfirmed: $0.strCreativeCommonsConfirmed,
                    dateModified: $0.dateModified,
                    drinkAlternate: $0.strDrinkAlternate,
                    imageSource: $0.strImageSource,
                    ingredients: ingredients,
                    instructions: $0.strInstructions,
                    mealID: $0.idMeal,
                    name: $0.strMeal,
                    source: URL(string: $0.strSource ?? ""),
                    tags: $0.strTags,
                    thumbnailURL: URL(string: $0.strMealThumb ?? ""),
                    youtubeURL: URL(string: $0.strYoutube ?? "")
                )
            }
        }
    }
    
    private struct RemoteDetailsItem: Decodable {
        let dateModified: String?
        let idMeal: String
        let strArea: String
        let strCategory: String
        let strCreativeCommonsConfirmed: String?
        let strDrinkAlternate: String?
        let strImageSource: String?
        let strIngredients: [String]
        let strInstructions: String
        let strMeal: String
        let strMealThumb: String?
        let strMeasurements: [String]
        let strSource: String?
        let strTags: String?
        let strYoutube: String?
        
        private enum CodingKeys: String, CodingKey {
            case dateModified
            case idMeal
            case strArea
            case strCategory
            case strCreativeCommonsConfirmed
            case strDrinkAlternate
            case strImageSource
            case strIngredients
            case strInstructions
            case strMeal
            case strMealThumb
            case strMeasurements
            case strSource
            case strTags
            case strYoutube
        }
        
        init(
            from decoder: Decoder
        ) throws {
            let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.dateModified = try container.decodeIfPresent(String.self, forKey: .dateModified)
            self.idMeal = try container.decode(String.self, forKey: .idMeal)
            self.strArea = try container.decode(String.self, forKey: .strArea)
            self.strCategory = try container.decode(String.self, forKey: .strCategory)
            self.strCreativeCommonsConfirmed = try container.decode(String?.self, forKey: .strCreativeCommonsConfirmed)
            self.strDrinkAlternate = try container.decode(String?.self, forKey: .strDrinkAlternate)
            self.strImageSource = try container.decode(String?.self, forKey: .strImageSource)
            
            self.strIngredients = try dynamicContainer
                .allKeys
                .filter { $0.stringValue.hasPrefix("strIngredient") }
                .sorted { $0.stringValue < $1.stringValue }
                .compactMap { try dynamicContainer.decodeIfPresent(String.self, forKey: DynamicCodingKeys(stringValue: $0.stringValue)!) }
                .filter{ !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            
            self.strInstructions = try container.decode(String.self, forKey: .strInstructions)
            self.strMeal = try container.decode(String.self, forKey: .strMeal)
            self.strMealThumb = try container.decode(String.self, forKey: .strMealThumb)
            
            self.strMeasurements = try dynamicContainer
                .allKeys
                .filter { $0.stringValue.hasPrefix("strMeasure") }
                .sorted { $0.stringValue < $1.stringValue }
                .compactMap { try dynamicContainer.decodeIfPresent(String.self, forKey: DynamicCodingKeys(stringValue: $0.stringValue)!) }
                .filter{ !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            
            self.strSource = try container.decode(String?.self, forKey: .strSource)
            self.strTags = try container.decode(String?.self, forKey: .strTags)
            self.strYoutube = try container.decode(String.self, forKey: .strYoutube)
        }
    }
    
    private static var OK_200: Int { return 200 }
    
    static func map(
        _ data: Data,
        _ response: HTTPURLResponse
    ) throws -> DessertDetailsItem {
        guard
            response.statusCode == OK_200
        else {
            throw Error.unexpectedServerResponse
        }
        
        let root = try JSONDecoder().decode(Root.self, from: data)
        
        guard
            let dessertDetailsItem = root.dessertDetailsItems.first
        else {
            throw Error.emptyServerResponse
        }
        
        return dessertDetailsItem
    }
}
