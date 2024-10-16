
# ImageLoader

**ImageLoader** is a lightweight Swift SDK designed to load images asynchronously from a URL and cache them using `NSCache`. It also provides an extension to `UIImageView` in UIKit, making it easy to load and display images in your app with caching enabled.

## Features

- Asynchronously loads images from a URL.
- Caches images using `NSCache` to minimize network usage.
- Provides a convenient `UIImageView` extension for seamless integration with UIKit.
- Automatically handles image loading cancellation, making it ideal for use in table or collection views.
- Provides error handling and allows setting a placeholder image in case of failure.

## Installation

To add **ImageLoader** to your project:
Add the repository URL to your project’s package dependencies.

## Usage

### Loading an Image into a `UIImageView`

Using **ImageLoader**, you can load an image from a URL and cache it with just a few lines of code. The library provides an extension for `UIImageView` to simplify the process.

```swift
let imageView = UIImageView()
let url = NSURL(string: "https://example.com/image.png")!

do {
    try imageView.loadImage(from: url, errorPlaceholderImage: UIImage(named: "placeholder"))
} catch {
    print("Failed to load image: \(error.localizedDescription)")
}
```

### Cancelling Image Loading

In cases where the  `UIImageView`  is reused (e.g., in a table or collection view), you may want to cancel any ongoing image loading.

```swift
imageView.cancelLoading()
```

### Error Handling

Errors during image loading (e.g., network issues) are captured in the custom  `CachedImageLoaderError`  enum:

-   `.errorLoading(Error)`: An error occurred during the download.
-   `.errorDecoding`: The downloaded data could not be decoded as an image.
-   `.cancelled`: The operation was manually cancelled.

### Example of Usage in UITableViewCell

To effectively use this SDK with reusable views like  `UITableViewCell`, you should cancel image loading before the cell is reused.

```swift
override func prepareForReuse() {
    super.prepareForReuse()
    imageView.cancelLoading()
}
```

### UIImageLoader Singleton

The  `UIImageLoader.shared`  instance manages image loading and caching. By default, images are cached in memory using  `NSCache`, making subsequent requests faster.

### Custom Placeholder

If an error occurs during image loading, you can specify a custom placeholder image:

```swift
let placeholder = UIImage(named: "errorPlaceholder")
try? imageView.loadImage(from: url, errorPlaceholderImage: placeholder)
```

## API Documentation

### CachedImageLoader

#### Methods

-   **`loadImage(from url: NSURL, completion: @escaping (Result<UIImage, Error>) -> Void) -> UUID?`**  
    Loads an image from the provided URL and caches it if successful. Returns a  `UUID`  for the request which can be used to cancel the operation.
    
-   **`cancelLoading(id: UUID)`**  
    Cancels an ongoing image load operation associated with the provided  `UUID`.
    

### UIImageLoader

#### Methods

-   **`load(from url: NSURL, for imageView: UIImageView, errorPlaceholderImage: UIImage? = nil)`**  
    Loads an image from the URL and sets it in the provided  `UIImageView`.
    
-   **`cancel(for imageView: UIImageView)`**  
    Cancels the image loading operation for the specified  `UIImageView`.
    
-   **`cancelAll()`**  
    Cancels all ongoing image loading operations.
    

### UIImageView Extension

#### Methods

-   **`loadImage(from url: NSURL, errorPlaceholderImage: UIImage? = nil)`**  
    Loads an image directly into the  `UIImageView`  using  `UIImageLoader`.
    
-   **`cancelLoading()`**  
    Cancels the image loading operation for the  `UIImageView`.
