//
//  FlowCoordinatorDependencyProvider.swift
//  Digii_Assessment
//
//  Created by Shreyansh Mishra on 25/02/24.
//

import UIKit

protocol PhotosListFlowCoordinatorDependencyProvider: AnyObject {
    func photosListNavigationController(navigator: PhotoListNavigator) -> UINavigationController
    
    func photoDetailsController(_ id: String) -> UIViewController
}

protocol ApplicationFlowCoordinatorDependencyProvider: PhotosListFlowCoordinatorDependencyProvider {}
