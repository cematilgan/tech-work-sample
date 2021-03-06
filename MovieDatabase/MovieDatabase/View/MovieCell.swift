//
//  MovieCell.swift
//  MovieDatabase
//
//  Created by Cem Atilgan on 2020-09-16.
//  Copyright © 2020 Cem Atilgan. All rights reserved.
//

import UIKit

enum MovieCellConfigureState {
    case data(Movie)
    case loading
}

class MovieCell: BaseTableViewCell {

    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var ratingLabel: UILabel!
    @IBOutlet private weak var genreLabel: UILabel!
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var imageLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var rankLabel: UILabel!

    private var imageService = ImageService()

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        rankLabel.font = UIFont.preferredFont(for: .headline, weight: .semibold)
        posterImageView.alpha = 0
        stackView.alpha = 0
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.posterImageView.image = nil
        self.titleLabel.text = ""
        self.ratingLabel.text = ""
        self.genreLabel.text = ""
        self.rankLabel.text = ""
        imageService.cancelAllRequests()
    }

    func configure(for state: MovieCellConfigureState, rank: Int?) {
        switch state {
        case .loading:
            posterImageView.alpha = 0
            stackView.alpha = 0
            loadingIndicator.startAnimating()
        case .data(let movie):
            stackView.alpha = 1
            titleLabel.text = movie.title
            genreLabel.text = "Genre: " + ((GenreService.shared.genre(for: movie)?.name) ?? "")
            ratingLabel.text = "Rating: \(movie.rating)"
            loadingIndicator.stopAnimating()
            imageLoadingIndicator.startAnimating()
            loadImage(for: movie)
            if let rank = rank {
                rankLabel.text = "\(rank)."
            } else {
                rankLabel.text = ""
                rankLabel.isHidden = true
            }
        }
    }

    private func loadImage(for movie: Movie) {
        let imageURL = URL(string: URLStrings.baseImageURL + movie.posterPath)
        imageService.getImage(url: imageURL) { [weak self](result) in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self?.posterImageView.image = image
                    self?.posterImageView.alpha = 1
                    self?.imageLoadingIndicator.stopAnimating()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.posterImageView.image = UIImage(systemName: "burst")
                    self?.imageLoadingIndicator.stopAnimating()
                    print(error)
                }
            }
        }
    }
}

