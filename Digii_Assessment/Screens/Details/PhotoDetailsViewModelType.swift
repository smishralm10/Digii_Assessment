//
//  PhotoDetailsViewModelType.swift
//  Digii_Assessment
//
//  Created by Shreyansh Mishra on 26/02/24.
//

import UIKit
import Combine

struct PhotoDetailsViewModelInput {
    let appear: AnyPublisher<Void, Never>
}

enum PhotoDetailsState {
    case loading
    case success(PhotoViewModel)
    case failure(Error)
}

extension PhotoDetailsState: Equatable {
    static func == (lhs: PhotoDetailsState, rhs: PhotoDetailsState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading): return true
        case (.success(let lhsPhoto), .success(let rhsPhoto)): return lhsPhoto == rhsPhoto
        case (.failure, .failure): return true
        default: return false
        }
    }
}

typealias PhotoDetailsViewModelOutput = AnyPublisher<PhotoDetailsState, Never>

protocol PhotoDetailsViewModelType: AnyObject {
    func transform(input: PhotoDetailsViewModelInput) -> PhotoDetailsViewModelOutput
}
