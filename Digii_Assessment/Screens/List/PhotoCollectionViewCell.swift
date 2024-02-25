//
//  PhotoCollectionViewCell.swift
//  Digii_Assessment
//
//  Created by Shreyansh Mishra on 25/02/24.
//

import UIKit
import Combine

class PhotoCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "PhotoCollectionViewCell"
    
    private var cancellable: AnyCancellable?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let author: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dimensions: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancelImageLoading()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(imageView)
        addSubview(author)
        addSubview(dimensions)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6),
            
            author.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
            author.leadingAnchor.constraint(equalTo: leadingAnchor),
            author.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            dimensions.topAnchor.constraint(equalTo: author.bottomAnchor, constant: 4),
            dimensions.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimensions.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    func configure(imageName: String, title: String, subtitle: String) {
        imageView.image = UIImage(named: imageName)
        author.text = title
        dimensions.text = subtitle
    }
}

extension PhotoCollectionViewCell {
    
    func bind(to viewModel: PhotoViewModel) {
        cancelImageLoading()
        author.text = viewModel.author
        dimensions.text = "\(viewModel.width) x \(viewModel.height)"
        cancellable = viewModel.image
            .sink { [weak self] image in
                guard let strongSelf = self else { return }
                strongSelf.showImage(image: image)
            }
    }
    
    func showImage(image: UIImage?) {
        cancelImageLoading()
        UIView.transition(
            with: imageView,
            duration: 0.3,
            options: [.curveEaseIn, .transitionCrossDissolve]
        ) {
            self.imageView.image = image
        }
    }
   
    func cancelImageLoading() {
        imageView.image = nil
        cancellable?.cancel()
    }
}
