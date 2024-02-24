//
//  NetworkService.swift
//  Digii_Assessment
//
//  Created by Shreyansh Mishra on 24/02/24.
//

import Foundation
import Combine

protocol NetworkServiceType: AnyObject {
    @discardableResult
    func load<T>(_ resource: Resource<T>) -> AnyPublisher<T, Error>
}

final class NetworkService: NetworkServiceType {
    private let session: URLSession
    
    init(
        session: URLSession = URLSession(
            configuration: URLSessionConfiguration.ephemeral
        )
    ) {
        self.session = session
    }
    
    @discardableResult
    func load<T>(_ resource: Resource<T>) -> AnyPublisher<T, Error> where T : Decodable {
        guard let request = resource.request else {
            return Fail(error: NetworkError.invalidRequest).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .requestJSON()
    }
    
}

enum NetworkError: Error {
    case invalidRequest
    case invalidResponse
    case dataLoadingError(statusCode: Int, data: Data)
    case jsonDecodingError(error: Error)
}
