//
//  NetworkServiceTest.swift
//  Digii_AssessmentTests
//
//  Created by Shreyansh Mishra on 24/02/24.
//

import Foundation
import XCTest
import Combine
@testable import Digii_Assessment

class NetworkServiceTest: XCTestCase {
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        return URLSession(configuration: config)
    }()
    
    private lazy var networkService = NetworkService(session: session)
    private let resource = Resource<Photos>.photos(page: 1)
    private lazy var photosJsonData: Data = {
        let url = Bundle(for: NetworkServiceTest.self).url(forResource: "Photos", withExtension: "json")
        guard let resourceURL = url, let data =  try? Data(contentsOf: resourceURL) else {
            XCTFail("Failed to create data object from string!")
            return Data()
        }
        return data
    }()
    
    private var cancellables = Set<AnyCancellable>()
    
    override func setUp() {
        URLProtocol.registerClass(URLProtocolMock.self)
    }
    
    func test_loadFinishedSuccessfully() {
        var result: Result<Photos, Error>?
        let expectation = self.expectation(description: "networkServiceExpectation")
        URLProtocolMock.requestHandler = { request in
            let response = HTTPURLResponse(url: self.resource.url, statusCode: 200, httpVersion: nil, headerFields: nil)
            return (response!, self.photosJsonData)
        }
        
        networkService.load(resource)
            .sinkToResult { 
                result = $0
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        self.waitForExpectations(timeout: 1.0)
        guard case let .success(photos)  = result else {
            XCTFail()
            return
        }
        XCTAssertEqual(photos.count, 10)
    }
}

