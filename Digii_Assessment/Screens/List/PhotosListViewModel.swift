//
//  PhotoListViewModel.swift
//  Digii_Assessment
//
//  Created by Shreyansh Mishra on 25/02/24.
//

import Foundation
import UIKit.UIImage
import Combine

final class PhotosListViewModel: PhotosListViewModelType {
    
    private weak var navigator: PhotoListNavigator?
    private let useCase: PhotosUseCaseType
    private var cancellables: [AnyCancellable] = []
    
    init(navigator: PhotoListNavigator, useCase: PhotosUseCaseType) {
        self.navigator = navigator
        self.useCase = useCase
    }
    
    func transform(input: PhotosListViewModelInput) -> PhotosListViewModelOutput {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
        input.selection
            .sink { [unowned self] id in
                self.navigator?.showDetails(forPhoto: id)
            }
            .store(in: &cancellables)
        
        let photos = input.paginate
            .flatMap { [unowned self] page in
                self.useCase.fetchPhotos(page: page, limit: 100)
            }
            .map { result -> PhotosListState in
                switch result {
                case let .success(photos) where photos.isEmpty: return .noResults
                case let .success(photos): return .success(self.viewModels(from: photos))
                case let .failure(error): return .failure(error)
                }
            }
            .eraseToAnyPublisher()
        
        let initialState: PhotosListViewModelOutput = Just(.idle).eraseToAnyPublisher()
        return Publishers.Merge(initialState, photos).eraseToAnyPublisher()
    }
    
    private func viewModels(from photos: Photos) -> [PhotoViewModel] {
        return photos.map {
            PhotoViewModel(
                id: $0.id,
                author: $0.author,
                width: $0.width,
                height: $0.height,
                image: self.useCase.loadImage(for: $0)
            )
        }
    }
}
