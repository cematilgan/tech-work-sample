//
//  ImageService.swift
//  MovieDatabase
//
//  Created by Cem Atilgan on 2020-09-16.
//  Copyright © 2020 Cem Atilgan. All rights reserved.
//

import UIKit

enum ImageLoaderError: Error {
    case imageNotLoaded
}

class ImageService {

    private let imageCache: NSCache<NSString, UIImage> = NSCache<NSString, UIImage>()
    private var tasks: Set<URLSessionTask> = []

    func getImage(url: URL?, isFavorite: Bool = false, completion: @escaping (Result<UIImage,ImageLoaderError>)->Void) {
        guard let imageURL = url else {
            completion(.failure(.imageNotLoaded))
            return
        }

        if let cachedImage = imageCache.object(forKey: imageURL.absoluteString as NSString) {
            completion(.success(cachedImage))
        } else if let cachedImage = FavoritesService.images[imageURL.absoluteString], let image = cachedImage.getImage() {
            completion(.success(image))
        } else {
            let task = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                guard error == nil else {
                    completion(.failure(.imageNotLoaded))
                    return
                }
                if let data = data,
                    let image = UIImage(data: data) {
                    if isFavorite {
                        FavoritesService.addImage(Image(withImage: image), forKey: imageURL.absoluteString)
                    }
                    completion(.success(image))
                } else {
                    completion(.failure(.imageNotLoaded))
                }
            }
            task.resume()
            tasks.insert(task)
        }
    }

    func cancelAllRequests() {
        tasks.forEach { $0.cancel() }
    }
}
