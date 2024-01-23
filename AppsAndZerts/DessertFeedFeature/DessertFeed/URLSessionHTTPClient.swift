//
//  URLSessionHTTPClient.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/22/24.
//

import Foundation

enum URLSessionHTTPClient {
    enum Error: Swift.Error {
        case unexpectedServerError
    }
        
    static func makeRequest() async throws -> (data: Data, httpURLResponse: HTTPURLResponse) {
        let url = URL(string: "http://any-url.com")!
        let request = URLRequest(url: url)
        
        let (data, urlResponse) = try await URLSession.shared.data(for: request)
        
        guard
            let httpURLResponse = urlResponse as? HTTPURLResponse
        else {
            throw Error.unexpectedServerError
        }
        
        return (data, httpURLResponse)
    }
}
