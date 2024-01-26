//
//  URLSessionProtocol.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/24/24.
//

import Foundation

protocol URLSessionProtocol {
    typealias Response = (data: Data, urlResponse: URLResponse)
    
    func data(for request: URLRequest) async throws -> Response
}

extension URLSession: URLSessionProtocol {
    func data(for request: URLRequest) async throws -> Response {
        try await data(for: request, delegate: nil)
    }
}
