//
//  ApplicationComponentsFactory.swift
//  Digii_Assessment
//
//  Created by Shreyansh Mishra on 25/02/24.
//

import UIKit

final class ApplicationComponentsFactory {
    private let servicesProvider: ServicesProvider
    
    fileprivate lazy var useCase: PhotosUseCaseType = PhotosUseCase(
        networkService: servicesProvider.network,
        imageLoaderService: servicesProvider.imageLoader
    )
    
    init(servicesProvider: ServicesProvider = .defaultProvider()) {
        self.servicesProvider = servicesProvider
    }
}

extension ApplicationComponentsFactory: ApplicationFlowCoordinatorDependencyProvider {
    func photosListNavigationController(navigator: PhotoListNavigator) -> UINavigationController {
        let vm = PhotosListViewModel(navigator: navigator, useCase: useCase)
        let vc = PhotosListViewController(viewModel: vm)
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.navigationBar.tintColor = .label
        return navigationController
    }
    
    func photoDetailsController(_ id: String) -> UIViewController {
        let vm =  PhotoDetailsViewModel(id: id, useCase: useCase)
        let vc = PhotoDetailsViewController(viewModel: vm)
        return vc
    }
}
