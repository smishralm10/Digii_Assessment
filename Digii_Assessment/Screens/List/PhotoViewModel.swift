//
//  PhotoViewModel.swift
//  Digii_Assessment
//
//  Created by Shreyansh Mishra on 25/02/24.
//

import Foundation
import UIKit.UIImage
import Combine

struct PhotoViewModel {
    let id: String
    let author: String
    let width: Int
    let height: Int
    let image: AnyPublisher<UIImage?, Never>
}

extension PhotoViewModel: Hashable {
    static func == (lhs: PhotoViewModel, rhs: PhotoViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
