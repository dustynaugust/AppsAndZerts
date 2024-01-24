//
//  ResourceLoader.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/22/24.
//

import Foundation

struct ResourceLoader<Resource> {
    enum Error: Swift.Error {
        case unexpectedServerResponse
    }
    
    typealias Map = (Data, HTTPURLResponse) throws -> Resource
    typealias DataLoader = (URLRequest) async throws -> (Data, URLResponse)
    
    private let dataLoader: DataLoader
    
    init(
        dataLoader: @escaping DataLoader
    ) {
        self.dataLoader = dataLoader
    }
    
    func loadResource(
        from request: URLRequest,
        map: Map
    ) async throws -> Resource {
        let (data, urlResponse) = try await dataLoader(request)
        
        guard
            let httpURLResponse = urlResponse as? HTTPURLResponse
        else {
            throw Error.unexpectedServerResponse
        }
        
        return try map(data, httpURLResponse)
    }
}


