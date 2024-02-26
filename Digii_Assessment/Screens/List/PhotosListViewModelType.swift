//
//  PhotoListViewModelType.swift
//  Digii_Assessment
//
//  Created by Shreyansh Mishra on 25/02/24.
//

import Foundation
import Combine

struct PhotosListViewModelInput {
    let appear: AnyPublisher<Void, Never>
    let paginate: AnyPublisher<Int, Never>
    let selection: AnyPublisher<String, Never>
}

enum PhotosListState {
    case idle
    case loading
    case success([PhotoViewModel])
    case noResults
    case failure(Error)
}

extension PhotosListState: Equatable {
    static func == (lhs: PhotosListState, rhs: PhotosListState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.loading, .loading): return true
        case (.success(let lhsPhotos), .success(let rhsPhotos)): return lhsPhotos == rhsPhotos
        case (.noResults, .noResults): return true
        case (.failure, .failure): return true
        default: return false
        }
    }
}

typealias PhotosListViewModelOutput = AnyPublisher<PhotosListState, Never>

protocol PhotosListViewModelType {
    func transform(input: PhotosListViewModelInput) -> PhotosListViewModelOutput
}
