//
//  DessertDetailsItem.swift
//  AppsAndZertsTests
//
//  Created by Dustyn August on 1/27/24.
//

import Foundation

struct DessertDetailsItem: Equatable {
    let area: String
    let category: String
    let creativeCommonsConfirmed: String?
    let dateModified: String? // TODO: Move to Date?
    let drinkAlternate: String?
    let imageSource: String?
    let ingredients: [Ingredient]
    let instructions: String
    let mealID: String
    let name: String
    let source: URL?
    let tags: String?
    let thumbnailURL: URL?
    let youtubeURL: URL?
}
