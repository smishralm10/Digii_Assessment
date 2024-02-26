//
//  ApplicationFlowCoordinator.swift
//  Digii_Assessment
//
//  Created by Shreyansh Mishra on 25/02/24.
//

import UIKit

class ApplicationFlowCoordinator: FlowCoordinator {
    typealias DependencyProvider = ApplicationFlowCoordinatorDependencyProvider
    
    private let window: UIWindow
    private let dependencyProvider: DependencyProvider
    private var childCoordinators = [FlowCoordinator]()

    init(window: UIWindow, dependencyProvider: DependencyProvider) {
        self.window = window
        self.dependencyProvider = dependencyProvider
    }
    
    func start() {
        let listFlowCoordinator = PhotosListFlowCoordinator(
            window: window,
            dependencyProvider: dependencyProvider
        )
        childCoordinators = [listFlowCoordinator]
        listFlowCoordinator.start()
    }
}
