//
//  PhotosUseCaseTest.swift
//  Digii_AssessmentTests
//
//  Created by Shreyansh Mishra on 25/02/24.
//

import Foundation
import XCTest
import Combine
@testable import Digii_Assessment

class PhotosUseCaseTest: XCTestCase {
    private let networkService = NetworkServiceMock()
    private let imageLoaderService = ImageLoaderServiceMock()
    private var useCase: PhotosUseCase!
    private var cancellables = Set<AnyCancellable>()
    
    override func setUp() {
        useCase = PhotosUseCase(
            networkService: networkService,
            imageLoaderService: imageLoaderService
        )
    }
    
    func test_fetchPhotosSucceeds() {
        var result: Result<Photos, Error>!
        let expectation = self.expectation(description: "photos")
        let photos = Photos.loadFromFile("Photos.json")
        networkService.responses["/v2/list"] = photos
        
        useCase.fetchPhotos(page: 1)
            .sinkToResult {
                result = $0
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1.0, handler: nil)
        guard case .success = result else  {
            XCTFail()
            return
        }
    }
    
    func test_loadsImageFromNetwork() {
        let photos = Photos.loadFromFile("Photos.json")
        let photo = photos.first!
        var result: UIImage?
        
        let expectation = self.expectation(description: "loadImage")
        imageLoaderService.loadImageFromReturnValue = Just(UIImage()).eraseToAnyPublisher()
        
        useCase.loadImage(for: photo)
            .sink {
                result = $0
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertNotNil(result)
    }
}

extension Decodable {
    static func loadFromFile(_ filename: String) -> Self {
        do {
            let path = Bundle(for: PhotosUseCaseTest.self).path(forResource: filename, ofType: nil)!
            let data = try Data(contentsOf: URL(filePath: path))
            return try JSONDecoder().decode(Self.self, from: data)
        } catch {
            fatalError("Error: \(error)")
        }
    }
}
