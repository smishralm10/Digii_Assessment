//
//  ImageLoaderService.swift
//  Digii_Assessment
//
//  Created by Shreyansh Mishra on 24/02/24.
//

import Foundation
import UIKit.UIImage
import Combine

protocol ImageLoaderServiceType: AnyObject {
    func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never>
}

final class ImageLoaderService: ImageLoaderServiceType {
    private let cache: ImageCacheType = ImageCache()
    
    func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never> {
        if let image = cache.image(for: url) {
            return Just(image).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { (data, response) -> UIImage? in
                return UIImage(data: data)
            }
            .catch { _ in return Just(nil) }
            .handleEvents(receiveOutput: { [weak self] image in
                guard let strongSelf = self,
                      let image = image else { return }
                strongSelf.cache.insertImage(image, for: url)
            })
            .print("Image loading \(url):")
            .eraseToAnyPublisher()
    }
}
