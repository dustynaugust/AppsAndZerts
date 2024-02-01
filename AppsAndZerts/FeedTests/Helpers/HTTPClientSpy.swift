//
//  HTTPClientSpy.swift
//  AppsAndZertsTests
//
//  Created by Dustyn August on 1/26/24.
//

import Foundation

@testable import AppsAndZerts

class HTTPClientSpy: URLSessionProtocol {
    typealias Result = Swift.Result<Response, Error>
    
    private let result: Result
    private(set) var urlRequests = [URLRequest]()
    
    init(
        result: Result
    ) {
        self.result = result
    }
    
    func data(
        for request: URLRequest
    ) async throws -> Response {
        urlRequests.append(request)
        
        return try result.get()
    }
}
