//
//  XCTestCase+Error.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/22/24.
//  Note: This is code from my personal toolkit
//

import XCTest

extension XCTestCase {
    func expect<T>(
        _ expression: @autoclosure () async throws -> T,
        throws expectedError: Error,
        in file: StaticString = #file,
        line: UInt = #line
    ) async {
        let expectedNSError = expectedError as NSError
        await expect(try await expression(), throws: expectedNSError, in: file, line: line)
    }
    
    func expect<T>(
        _ expression: @autoclosure () async throws -> T,
        throws expectedError: NSError,
        in file: StaticString = #file,
        line: UInt = #line
    ) async {
        do {
            _ = try await expression()
            XCTFail("No error thrown. Expecting \(expectedError)", file: file, line: line)
        } catch {
            let thrownError = error as NSError
            
            if thrownError.domain != expectedError.domain {
                XCTFail("Throws unexpected error domain \"\(thrownError.domain)\". Expecting \"\(expectedError.domain)\".", file: file, line: line)
            }
            
            if thrownError.code != expectedError.code {
                XCTFail("Throws unexpected error code \"\(thrownError.code)\". Expecting \"\(expectedError.code)\".", file: file, line: line)
            }
        }
    }
    
    func expect<T, E>(
        _ expression: @autoclosure () async throws -> T,
        throws expectedError: E,
        in file: StaticString = #file,
        line: UInt = #line
    ) async where E: Error & Equatable {
        do {
            _ = try await expression()
            XCTFail("No error thrown. Expecting \(expectedError)", file: file, line: line)
        } catch {
            guard 
                let actualError = error as? E
            else {
                XCTFail("Throws unexpected error type \"\(String(reflecting: error))\". Expecting \"\(String(reflecting: E.self))\".", file: file, line: line)
                return
            }
            
            guard
                actualError == expectedError
            else {
                XCTFail("Throws unexpected error \"\(actualError)\". Expecting \"\(expectedError)\".", file: file, line: line)
                return
            }
            
            // Success, the expected error was thrown
        }
    }
    
    func expect<T, E>(
        _ expression: @autoclosure () async throws -> T,
        throwsErrorOfType expectedErrorType: E.Type,
        in file: StaticString = #file,
        line: UInt = #line
    ) async where E: Error {
        do {
            _ = try await expression()
            XCTFail("Expression did not throw an error", file: file, line: line)
            
        } catch {
            guard
                error is E
            else {
                XCTFail("Throws unexpected error type \(String(reflecting: error.self)). Expected type \(String(reflecting: expectedErrorType)))", file: file, line: line)
                return
            }
            
            // Success, an error of type E was thrown
        }
    }
    
    func expectErrorThrown<T>(
        by expression: @autoclosure () async throws -> T,
        in file: StaticString = #file,
        line: UInt = #line
    ) async {
        do {
            _ = try await expression()
            XCTFail("Expression did not throw an error", file: file, line: line)
            
        } catch {
            // Success, an error was thrown
        }
    }
}
