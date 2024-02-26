//
//  PhotosListFlowCoordinator.swift
//  Digii_Assessment
//
//  Created by Shreyansh Mishra on 25/02/24.
//

import Foundation
import UIKit

class PhotosListFlowCoordinator: FlowCoordinator {
    fileprivate let window: UIWindow
    fileprivate var listNavigationController: UINavigationController?
    fileprivate let dependencyProvider: PhotosListFlowCoordinatorDependencyProvider
    
    init(
        window: UIWindow,
        dependencyProvider: PhotosListFlowCoordinatorDependencyProvider
    ) {
        self.window = window
        self.dependencyProvider = dependencyProvider
    }
    
    func start() {
        let listNavigationController = dependencyProvider
            .photosListNavigationController(navigator: self)
        window.rootViewController = listNavigationController
        self.listNavigationController = listNavigationController
    }
}

extension PhotosListFlowCoordinator: PhotoListNavigator {
    func showDetails(forPhoto id: String) {
        let controller = self.dependencyProvider.photoDetailsController(id)
        listNavigationController?.pushViewController(controller, animated: true)
    }
}
