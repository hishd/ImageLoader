//
//  File.swift
//  
//
//  Created by Hishara Dilshan on 2024-07-06.
//

import Foundation
import UIKit

///Error enum for CachedImageLoader
enum CachedImageLoaderError: Error {
    case errorLoading(Error)
    case errorDecording
    case cancelled
}

extension CachedImageLoaderError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .errorLoading(_):
            "An error occured during image loading"
        case .errorDecording:
            "An error occurred during image loading. No image data found."
        case .cancelled:
            "The operation was cancelled"
        }
    }
    
    var failureReason: String? {
        switch self {
        case .errorLoading(let error):
            "Could not load image. Error \(error.localizedDescription)"
        case .errorDecording:
            "Could not decode image data (no data found)."
        case .cancelled:
            "Operation was cancelled during image loading data task."
        }
    }
}

///CachedImageLoader is used to load the images from a URL and cache them in NSCache once successfully loaded
final class CachedImageLoader {
    //Using NSCache to cache the images
    private var cachedImages: NSCache = NSCache<NSURL, UIImage>()
    //Storing the URLSession tasks which handles loading images
    private var runningRequests: [UUID: URLSessionDataTask] = [:]
    //Accessing through singleton
    public static let publicCache = CachedImageLoader()
    
    /// Loading an image with the provided url and cache the image once loaded.
    /// If the image is previously cached and found, it will return through the completion handler.
    /// - Parameters:
    ///   - url: The URL which the image should be loaded from
    ///   - completion: Callback which returns a UIImage if the operation is successful
    /// - Returns: The UUID for each url request. This will be used to cancel the image load operation
    func loadImage(from url: NSURL, completion: @escaping (Result<UIImage, Error>) -> Void) throws -> UUID? {
        if let cachedImage = cachedImages.object(forKey: url) {
            completion(.success(cachedImage))
            return nil
        }
        
        let uuid = UUID()
        
        let dataTask = URLSession.shared.dataTask(with: url as URL) { data, response, error in
            let result: Result<UIImage, Error>
            defer {
                self.runningRequests.removeValue(forKey: uuid)
                completion(result)
            }
            
            if let data = data, let image = UIImage(data: data) {
                self.cachedImages.setObject(image, forKey: url, cost: data.count)
                result = .success(image)
                return
            }
            
            guard let error = error else {
                //No error found, but no data is found as well
                result = .failure(CachedImageLoaderError.errorDecording)
                return
            }
            
            if (error as NSError).code == NSURLErrorCancelled {
                result = .failure(CachedImageLoaderError.cancelled)
                return
            }
            
            result = .failure(CachedImageLoaderError.errorLoading(error))
        }
        
        runningRequests[uuid] = dataTask
        dataTask.resume()
        return uuid
    }
    
    /// Cancel Image load operation using the UUID
    /// - Parameters:
    /// - id: The UUID instance which the task is associated with. This will be used to cancel the data task and remove it from the running requests
    func cancelLoading(id: UUID) {
        runningRequests[id]?.cancel()
        runningRequests.removeValue(forKey: id)
    }
}
