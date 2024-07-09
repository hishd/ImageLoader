//
//  File.swift
//  
//
//  Created by Hishara Dilshan on 2024-07-06.
//

import Foundation
import UIKit

/// A helper class which is used to access the CachedImageLoader and load the image to the ImageView
public final class UIImageLoader {
    public static let shared = UIImageLoader()
    
    private let cachedImageLoader = CachedImageLoader.publicCache
    private var uuidDict = [UIImageView: UUID]()
    
    private init() {}
    
    /// Loading an image to an ImageView using the provided URL
    /// - Parameters:
    ///    - url: The URL of the resource
    ///    - imageView: The ImageView instance which the image should be loaded into
    ///    - errorPlaceholderImage: A placeholder image which is loaded into the ImageView if the operation fails
    public func load(from url: NSURL, for imageView: UIImageView, errorPlaceholderImage: UIImage? = nil) throws {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        
        imageView.addSubview(spinner)
        spinner.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        
        let token = try cachedImageLoader.loadImage(from: url) { result in
            defer {
                self.uuidDict.removeValue(forKey: imageView)
            }
            
            DispatchQueue.main.async {
                imageView.alpha = 0
                
                switch result {
                case .success(let image):
                    imageView.image = image
                case .failure(let error):
                    print(error.localizedDescription)
                    imageView.image = errorPlaceholderImage
                }
                
                spinner.stopAnimating()
                spinner.removeFromSuperview()
                UIView.animate(withDuration: 0.75, delay: 0) {
                    imageView.alpha = 1
                }
            }
        }
        
        if let token = token {
            self.uuidDict[imageView] = token
        }
    }
    
    /// Cancelling the image loading operation if it's no longer needed (eg: preparing the cells for reusing)
    /// - Parameters:
    ///  - imageView: The ImageView instance which the request should be cancelled with
    public func cancel(for imageView: UIImageView) {
        if let token = self.uuidDict[imageView] {
            cachedImageLoader.cancelLoading(id: token)
            self.uuidDict.removeValue(forKey: imageView)
        }
    }
    
    //// Cancelling all image loading operations of the ImageViews
    public func cancelAll() {
        uuidDict.keys.forEach {
            self.cancel(for: $0)
        }
    }
}
