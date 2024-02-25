//
//  PhotosUseCase.swift
//  Digii_Assessment
//
//  Created by Shreyansh Mishra on 25/02/24.
//

import Foundation
import Combine
import UIKit.UIImage


protocol PhotosUseCaseType {
    func fetchPhotos(page: Int, limit: Int) -> AnyPublisher<Result<Photos, Error>, Never>
    
    func loadImage(for photo: Photo) -> AnyPublisher<UIImage?, Never>
}

final class PhotosUseCase: PhotosUseCaseType {
    private let networkService: NetworkServiceType
    private let imageLoaderService: ImageLoaderServiceType
    
    init(networkService: NetworkServiceType, imageLoaderService: ImageLoaderServiceType) {
        self.networkService = networkService
        self.imageLoaderService = imageLoaderService
    }
    
    func fetchPhotos(page: Int, limit: Int = 100) -> AnyPublisher<Result<Photos, Error>, Never> {
        return networkService
            .load(Resource<Photos>.photos(page: 1))
            .map { .success($0) }
            .catch { error -> AnyPublisher<Result<Photos, Error>, Never> in
                Just(.failure(error)).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func loadImage(for photo: Photo) -> AnyPublisher<UIImage?, Never> {
        return Deferred { Just(photo.downloadURL) }
            .flatMap { [weak self] urlString -> AnyPublisher<UIImage?, Never> in
                guard let strongSelf = self,
                      let downloadURL = URL(string: urlString) else { return Just(nil).eraseToAnyPublisher() }
                return strongSelf.imageLoaderService.loadImage(from: downloadURL)
            }
            .share()
            .eraseToAnyPublisher()
    }
}
