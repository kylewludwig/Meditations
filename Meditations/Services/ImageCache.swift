//
// ImageCache.swift
//
// Copyright © 2021 Ten Percent Happier. All rights reserved.
//
// MICROSOFT REFERENCE SOURCE LICENSE (MS-RSL)
// This license governs use of the accompanying software. If you use the software, you accept this license.
// If you do not accept the license, do not use the software.
//
// https://referencesource.microsoft.com/license.html
//
// 1. Definitions
// - The terms "reproduce," "reproduction" and "distribution" have the same meaning here as under U.S.
//   copyright law.
// - "You" means the licensee of the software.
// - "Your company" means the company you worked for when you downloaded the software.
// - "Reference use" means use of the software within your company as a reference, in read only form, for the
//   sole purposes of debugging your products, maintaining your products, or enhancing the interoperability
//   of your products with the software, and specifically excludes the right to  distribute the software
//   outside of your company.
//
// 2. Grant of Rights
// (A) Copyright Grant- Subject to the terms of this license, the Licensor grants you a non-transferable,
//     non-exclusive, worldwide, royalty-free copyright license to reproduce the software for reference use.
// (B) Patent Grant- Subject to the terms of this license, the Licensor grants you a non-transferable,
//     non-exclusive, worldwide, royalty-free patent license under licensed patents for reference use.
//
// 3. Limitations
// (A) No Trademark License- This license does not grant you any rights to use the Licensor's name, logo, or
//     trademarks.
// (B) If you begin patent litigation against the Licensor over patents that you think may apply to the
//     software (including a cross-claim or counterclaim in a lawsuit), your license to the software
//     non-exclusive,
// (C) The software is licensed "as-is." You bear the risk of using it. The Licensor gives no express
//     warranties, guarantees or conditions. You may have additional consumer rights under your local laws
//     which this license cannot change. To the extent permitted under your local laws, the Licensor excludes
//     the implied warranties of merchantability, fitness for a particular purpose and non-infringement.
//

import UIKit
import Foundation

public class ImageCache {
  
  public static let publicCache = ImageCache()
  
  var placeholderImage = UIImage(named: "Rectangle")!

  private let cachedImages = NSCache<NSURL, UIImage>()

  private var loadingResponses = [NSURL: [(UIImage?) -> Void]]()

  public final func image(url: NSURL) -> UIImage? {
    return cachedImages.object(forKey: url)
  }

  // Returns the cached image if available, otherwise asynchronously loads and caches it.
  final func load(url: NSURL, completion: @escaping (UIImage?) -> Void) {
    // Check for a cached image.
    if let cachedImage = image(url: url) {
      DispatchQueue.main.async {
        completion(cachedImage)
      }
      return
    }

    // In case there are more than one requestor for the image, we append their completion block.
    if loadingResponses[url] != nil {
      loadingResponses[url]?.append(completion)
      return
    } else {
      loadingResponses[url] = [completion]
    }

    // Go fetch the image.
    ImageUrlProtocol.urlSession().dataTask(with: url as URL) { (data, _, error) in
      // Check for the error, then data and try to create the image.
      guard let responseData = data, let image = UIImage(data: responseData),
            let blocks = self.loadingResponses[url], error == nil else {
        DispatchQueue.main.async {
          completion(nil)
        }
        return
      }

      // Cache the image.
      self.cachedImages.setObject(image, forKey: url, cost: responseData.count)
      // Iterate over each requestor for the image and pass it back.
      for block in blocks {
        DispatchQueue.main.async {
          block(image)
        }
        return
      }
    }.resume()
  }
}
