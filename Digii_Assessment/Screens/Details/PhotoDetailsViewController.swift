//
//  PhotoDetailsViewController.swift
//  Digii_Assessment
//
//  Created by Shreyansh Mishra on 26/02/24.
//

import UIKit
import Combine

class PhotoDetailsViewController: UIViewController {

    private let viewModel: PhotoDetailsViewModelType
    private var cancellables = Set<AnyCancellable>()
    private let appear = PassthroughSubject<Void, Never>()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.startAnimating()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let loadingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(viewModel: PhotoDetailsViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Supported!")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bind(to: viewModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appear.send(())
    }
    
    private func configureUI() {
        view.addSubview(imageView)
        loadingView.addSubview(activityIndicator)
        view.addSubview(loadingView)
        
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func bind(to viewModel: PhotoDetailsViewModelType) {
        let input = PhotoDetailsViewModelInput(appear: appear.eraseToAnyPublisher())
        
        let output = viewModel.transform(input: input)

        output.sink(receiveValue: {[unowned self] state in
            self.render(state)
        }).store(in: &cancellables)
    }
    
    private func render(_ state: PhotoDetailsState) {
        switch state {
        case .loading:
            loadingView.isHidden = false
        case let .success(photoViewModel):
            loadingView.isHidden = true
            show(photoViewModel)
        case .failure(let error):
            loadingView.isHidden = true
            print(error)
        }
    }
    
    private func show(_ photoDetails: PhotoViewModel) {
        title = "ID: \(photoDetails.id)"
        photoDetails.image
            .assign(to: \UIImageView.image, on: self.imageView)
            .store(in: &cancellables)
    }
}
