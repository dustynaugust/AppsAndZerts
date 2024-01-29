//
//  DynamicCodingKeysTests.swift
//  AppsAndZertsTests
//
//  Created by Dustyn August on 1/28/24.
//

import XCTest

@testable import AppsAndZerts

final class DynamicCodingKeysTests: XCTestCase {
    
}

extension DynamicCodingKeysTests {
    func test_init_intValue() {
        XCTAssertNil(DynamicCodingKeys(intValue: 12))
    }
    
    func test_init_stringValue() throws {
        let anyStringValue = "any-string-value"
        let sut = try XCTUnwrap(DynamicCodingKeys(stringValue: anyStringValue))
        
        XCTAssertEqual(sut.stringValue, anyStringValue)
        XCTAssertNil(sut.intValue)
    }
}
