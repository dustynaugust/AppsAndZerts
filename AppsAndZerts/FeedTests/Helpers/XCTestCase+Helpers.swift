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

func anyValidDetailsResponse() throws -> URLSessionProtocol.Response {
    let anyValidDetailsJSON: String =
    #"""
    {
        "meals": [
            {
                "idMeal": "53049",
                "strMeal": "Apam balik",
                "strDrinkAlternate": null,
                "strCategory": "Dessert",
                "strArea": "Malaysian",
                "strInstructions": "Mix milk, oil and egg together. Sift flour, baking powder and salt into the mixture. Stir well until all ingredients are combined evenly.\r\n\r\nSpread some batter onto the pan. Spread a thin layer of batter to the side of the pan. Cover the pan for 30-60 seconds until small air bubbles appear.\r\n\r\nAdd butter, cream corn, crushed peanuts and sugar onto the pancake. Fold the pancake into half once the bottom surface is browned.\r\n\r\nCut into wedges and best eaten when it is warm.",
                "strMealThumb": "https://www.themealdb.com/images/media/meals/adxcbq1619787919.jpg",
                "strTags": null,
                "strYoutube": "https://www.youtube.com/watch?v=6R8ffRRJcrg",
                "strIngredient1": "Milk",
                "strIngredient2": "Oil",
                "strIngredient3": "Eggs",
                "strIngredient4": "Flour",
                "strIngredient5": "Baking Powder",
                "strIngredient6": "Salt",
                "strIngredient7": "Unsalted Butter",
                "strIngredient8": "Sugar",
                "strIngredient9": "Peanut Butter",
                "strIngredient10": "",
                "strIngredient11": "",
                "strIngredient12": "",
                "strIngredient13": "",
                "strIngredient14": "",
                "strIngredient15": "",
                "strIngredient16": "",
                "strIngredient17": "",
                "strIngredient18": "",
                "strIngredient19": "",
                "strIngredient20": "",
                "strMeasure1": "200ml",
                "strMeasure2": "60ml",
                "strMeasure3": "2",
                "strMeasure4": "1600g",
                "strMeasure5": "3 tsp",
                "strMeasure6": "1/2 tsp",
                "strMeasure7": "25g",
                "strMeasure8": "45g",
                "strMeasure9": "3 tbs",
                "strMeasure10": " ",
                "strMeasure11": " ",
                "strMeasure12": " ",
                "strMeasure13": " ",
                "strMeasure14": " ",
                "strMeasure15": " ",
                "strMeasure16": " ",
                "strMeasure17": " ",
                "strMeasure18": " ",
                "strMeasure19": " ",
                "strMeasure20": " ",
                "strSource": "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ",
                "strImageSource": null,
                "strCreativeCommonsConfirmed": null,
                "dateModified": null
            },
        ]
    }
    """#
    
    let jsonData = try XCTUnwrap(anyValidDetailsJSON.data(using: .utf8))
    let successfulHTTPURLResponse = try any200HTTPURLResponse()
    
    return (jsonData, successfulHTTPURLResponse)
}

func anyValidFeedResponse() throws -> URLSessionProtocol.Response {
    let anyValidFeedJSON: String =
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
    
    let jsonData = try XCTUnwrap(anyValidFeedJSON.data(using: .utf8))
    let successfulHTTPURLResponse = try any200HTTPURLResponse()
    
    return (jsonData, successfulHTTPURLResponse)
}
