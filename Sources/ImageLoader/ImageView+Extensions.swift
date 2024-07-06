//
//  File.swift
//  
//
//  Created by Hishara Dilshan on 2024-07-06.
//

import Foundation
import UIKit

/// Extensions for the UIIMageView type to enable calling the declared methods from Self
extension UIImageView {
    /// Loading the image using the provided URL through UIImageLoader
    func loadImage(from url: NSURL, errorPlaceholderImage: UIImage? = nil) throws {
        try UIImageLoader.shared.load(from: url, for: self, errorPlaceholderImage: errorPlaceholderImage)
    }
    /// Cancelling the image loading through UIImageLoader
    func cancelLoading() {
        UIImageLoader.shared.cancel(for: self)
    }
}

