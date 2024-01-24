//
//  URLSessionProtocol.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/24/24.
//

import Foundation

protocol URLSessionProtocol {
    typealias Response = (Data, URLResponse)
    
    func data(for request: URLRequest) async throws -> Response
}

extension URLSession: URLSessionProtocol { }
