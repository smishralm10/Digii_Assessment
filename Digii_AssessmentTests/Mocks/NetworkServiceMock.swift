//
//  NetworkServiceMock.swift
//  Digii_AssessmentTests
//
//  Created by Shreyansh Mishra on 25/02/24.
//

import Foundation
import Combine
@testable import Digii_Assessment

class NetworkServiceMock: NetworkServiceType {
    var loadCallsCount = 0
    var loadCalled: Bool {
        return loadCallsCount > 0
    }
    var responses = [String: Any]()
    
    func load<T>(_ resource: Resource<T>) -> AnyPublisher<T, Error> where T : Decodable {
        if let response = responses[resource.url.path] as? T {
            return Just(response).setFailureType(to: Error.self).eraseToAnyPublisher()
        } else if let error = responses[resource.url.path] as? NetworkError {
            return Fail(error: error).eraseToAnyPublisher()
        } else {
            return Fail(error: NetworkError.invalidRequest).eraseToAnyPublisher()
        }
    }
}
