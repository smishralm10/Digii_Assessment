//
//  PhotoDetailsViewModel.swift
//  Digii_Assessment
//
//  Created by Shreyansh Mishra on 26/02/24.
//

import Foundation
import Combine

class PhotoDetailsViewModel: PhotoDetailsViewModelType {
    private let id: String
    private let useCase: PhotosUseCaseType
    
    init(id: String, useCase: PhotosUseCaseType) {
        self.id = id
        self.useCase = useCase
    }
    
    func transform(input: PhotoDetailsViewModelInput) -> PhotoDetailsViewModelOutput {
        let photoDetails = input.appear
            .flatMap { [unowned self] _  in
                self.useCase.photoDetails(with: self.id)
            }
            .map { result -> PhotoDetailsState in
                switch result {
                case let .success(photo): return .success(self.viewModel(from: photo))
                case let .failure(error): return .failure(error)
                }
            }
            .eraseToAnyPublisher()
        let loading: PhotoDetailsViewModelOutput = input.appear.map({ _ in .loading}).eraseToAnyPublisher()
        
        return Publishers.Merge(loading, photoDetails).removeDuplicates().eraseToAnyPublisher()
    }
    
    private func viewModel(from photo: Photo) -> PhotoViewModel {
        return PhotoViewModel(
            id: photo.id,
            author: photo.author,
            width: photo.width,
            height: photo.height,
            image: useCase.loadImage(for: photo)
        )
    }
}
