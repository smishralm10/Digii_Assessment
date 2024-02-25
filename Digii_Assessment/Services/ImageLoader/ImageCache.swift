//
//  ImageLoader.swift
//  Digii_Assessment
//
//  Created by Shreyansh Mishra on 24/02/24.
//

import Foundation
import UIKit.UIImage

protocol ImageCacheType: AnyObject {
    func image(for url: URL) -> UIImage?
    func insertImage(_ image: UIImage?, for url: URL)
    func removeImage(for url: URL)
}

final class ImageCache: ImageCacheType {
    private let lock = NSLock()
    private let config: Config
    
    private lazy var imageCache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.countLimit = config.countLimit
        return cache
    }()
    
    private lazy var decodedImageCache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.totalCostLimit = config.memoryLimit
        return cache
    }()
    
    init(config: Config = Config.defaultConfig) {
        self.config = config
    }
    
    func image(for url: URL) -> UIImage? {
        lock.lock()
        defer { lock.unlock() }
        if let decodedImage = decodedImageCache.object(forKey: url as AnyObject) as? UIImage {
            return decodedImage
        }
        if let image = imageCache.object(forKey: url as AnyObject) as? UIImage {
            let decodedImage = image.decodedImage()
            decodedImageCache.setObject(
                image as AnyObject,
                forKey: url as AnyObject,
                cost: decodedImage.diskSize
            )
            return decodedImage
        }
        return nil
    }
    
    func insertImage(_ image: UIImage?, for url: URL) {
        guard let image = image else { return removeImage(for: url) }
        let decompressedImage = image.decodedImage()
        lock.lock()
        defer { lock.unlock() }
        imageCache.setObject(decompressedImage, forKey: url as AnyObject, cost: 1)
        decodedImageCache.setObject(
            image as AnyObject,
            forKey: url as AnyObject,
            cost: decompressedImage.diskSize
        )
    }
    
    func removeImage(for url: URL) {
        lock.lock()
        defer { lock.unlock() }
        imageCache.removeObject(forKey: url as AnyObject)
        decodedImageCache.removeObject(forKey: url as AnyObject)
    }
}

extension ImageCache {
    struct Config {
        let countLimit: Int
        let memoryLimit: Int
        
        static let defaultConfig = Config(countLimit: 100, memoryLimit: 1024 * 1024 * 100)
    }
}

extension UIImage {
    func decodedImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
        return renderer.image { _ in
            draw(at: .zero)
        }
    }
    
    var diskSize: Int {
        guard let cgImage = cgImage else { return 0 }
        return cgImage.bytesPerRow * cgImage.height
    }
}
