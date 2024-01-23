//
//  URLSessionHTTPClient.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/22/24.
//

import Foundation

protocol HTTPClient {
    func makeRequest(with request: URLRequest) async throws -> (data: Data, httpURLResponse: HTTPURLResponse)
}

struct URLSessionHTTPClient: HTTPClient {
    enum Error: Swift.Error {
        case unexpectedServerError
    }
        
    func makeRequest(
        with request: URLRequest
    ) async throws -> (data: Data, httpURLResponse: HTTPURLResponse) {
        let (data, urlResponse) = try await URLSession.shared.data(for: request)
        
        guard
            let httpURLResponse = urlResponse as? HTTPURLResponse
        else {
            throw Error.unexpectedServerError
        }
        
        return (data, httpURLResponse)
    }
}
