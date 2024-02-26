//
//  AlertViewModel.swift
//  Digii_Assessment
//
//  Created by Shreyansh Mishra on 26/02/24.
//

import Foundation

struct AlertViewModel {
    let title: String
    let description: String?
    
    static var dataLoadingError: AlertViewModel {
        let title = NSLocalizedString("Can't load results!", comment: "Can't load results!")
        let description = NSLocalizedString("Something went wrong. Try searching again...", comment: "Something went wrong. Try again...")
        return AlertViewModel(title: title, description: description)
    }
    
    static var noResults: AlertViewModel {
        let title = NSLocalizedString("No photos found!", comment: "No photos found!")
        let description = NSLocalizedString("Try again...", comment: "Try again...")
        return AlertViewModel(title: title, description: description)
    }
}
