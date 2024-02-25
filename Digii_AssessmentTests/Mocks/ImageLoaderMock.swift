//
//  ImageLoaderMock.swift
//  Digii_AssessmentTests
//
//  Created by Shreyansh Mishra on 24/02/24.
//

import Foundation
import UIKit.UIImage
import Combine
@testable import Digii_Assessment

class ImageLoaderServiceMock: ImageLoaderServiceType {
    var loadImageFromCallsCount = 0
    var loadImageFromCalled: Bool {
        return loadImageFromCallsCount > 0
    }
    var loadImageFromReceivedURL: URL?
    var loadImageFromReceivedInvocations: [URL] = []
    var loadImageFromReturnValue: AnyPublisher<UIImage?, Never>!
    var loadImageFromClosure: ((URL) -> AnyPublisher<UIImage?, Never>)?
    
    func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never> {
        loadImageFromCallsCount += 1
        loadImageFromReceivedURL = url
        loadImageFromReceivedInvocations.append(url)
        return loadImageFromClosure.map({ $0(url)}) ?? loadImageFromReturnValue
    }
}
