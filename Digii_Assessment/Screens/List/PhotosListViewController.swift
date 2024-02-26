//
//  PhotosListViewController.swift
//  Digii_Assessment
//
//  Created by Shreyansh Mishra on 25/02/24.
//

import UIKit
import Combine

class PhotosListViewController: UICollectionViewController {

    private lazy var dataSource = makeDataSource()
    private let viewModel: PhotosListViewModelType
    private let appear = PassthroughSubject<Void, Never>()
    private let paginate = PassthroughSubject<Int, Never>()
    private let selection = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 1
    
    private lazy var alertViewController = AlertViewController(nibName: nil, bundle: nil)
    
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
    
    
    init(viewModel: PhotosListViewModelType) {
        self.viewModel = viewModel
        super.init(collectionViewLayout: Self.createLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Supported!")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bind(to: viewModel)
        paginate.send(currentPage)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appear.send(())
    }
    
    private func configureUI() {
        title = NSLocalizedString("List", comment: "Photos List")
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.reuseIdentifier)
        
        loadingView.addSubview(activityIndicator)
        view.addSubview(loadingView)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func bind(to viewModel: PhotosListViewModelType) {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        let input = PhotosListViewModelInput(
            appear: appear.eraseToAnyPublisher(),
            paginate: paginate.eraseToAnyPublisher(),
            selection: selection.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        
        output.sink { [weak self] state in
            self?.render(state)
        }
        .store(in: &cancellables)
    }
    
    private func render(_ state: PhotosListState) {
        switch state {
        case .idle:
            alertViewController.view.isHidden = true
            loadingView.isHidden = true
            update(with: [], animate: true)
        case .loading:
            alertViewController.view.isHidden = true
            loadingView.isHidden = false
            update(with: [], animate: true)
        case .success(let photos):
            loadingView.isHidden = true
            alertViewController.view.isHidden = true
            var items = dataSource.snapshot().itemIdentifiers
            items.append(contentsOf: photos)
            update(with: items)
        case .noResults:
            alertViewController.view.isHidden = false
            alertViewController.showNoResults()
        case .failure(let error):
            alertViewController.view.isHidden = false
            alertViewController.showDataLoadingError()
            loadingView.isHidden = true
        }
    }
}

// MARK: - Define Layout
private extension PhotosListViewController {
    
    static func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(0.33)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        group.interItemSpacing = .fixed(10)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

// MARK: - Data Source
private extension PhotosListViewController {
    enum Section: CaseIterable {
        case photos
    }
    
    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, PhotoViewModel> {
        return UICollectionViewDiffableDataSource(collectionView: collectionView)
        { collectionView, indexPath, photo in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PhotoCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? PhotoCollectionViewCell else {
                assertionFailure("Failed to dequeue")
                return UICollectionViewCell()
            }
            cell.bind(to: photo)
            return cell
        }
    }
    
    func update(with photos: [PhotoViewModel], animate: Bool = true) {
        DispatchQueue.main.async {
            var snapshot = NSDiffableDataSourceSnapshot<Section, PhotoViewModel>()
            snapshot.appendSections(Section.allCases)
            snapshot.appendItems(photos, toSection: .photos)
            self.dataSource.apply(snapshot, animatingDifferences: animate)
        }
    }
}

// MARK: - Delegate
extension PhotosListViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let snapshot = dataSource.snapshot()
        selection.send(snapshot.itemIdentifiers[indexPath.row].id)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    // fetch next page at the end of list
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastSection = collectionView.numberOfSections - 1
        let lastItem = collectionView.numberOfItems(inSection: lastSection) - 1
        
        if indexPath.section == lastSection && indexPath.item == lastItem {
            currentPage += 1
            paginate.send(currentPage)
        }
    }
    
}
