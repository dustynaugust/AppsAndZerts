//
//  DynamicCodingKeys.swift
//  AppsAndZertsTests
//
//  Created by Dustyn August on 1/27/24.
//

import Foundation

struct DynamicCodingKeys: CodingKey {
    var intValue: Int?
    var stringValue: String
    
    init?(intValue: Int) {
        return nil
    }
    
    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
}
