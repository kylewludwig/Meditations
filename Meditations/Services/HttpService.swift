//
// HttpService.swift
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

import Foundation

public class HttpService {

  public typealias GenericResult<T> = (Result<T, Error>) -> Void
  
  public static func download<T: Decodable>(type: T.Type, from url: URL, completion: @escaping GenericResult<T>) {

    URLSession.shared.dataTask(with: url) { (data, response, error) in
      if let error = error {
        completion(.failure(error))
      }

      guard let response = response as? HTTPURLResponse else {
        completion(.failure(NetworkingError.invalidResponse))
        return
      }

      if 200 ... 299 ~= response.statusCode {
        if let data = data {
          do {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            completion(.success(decodedData))
          } catch {
            completion(.failure(DecodingError.dataFormatUnsupported))
          }
        } else {
          completion(.failure(DecodingError.noData))
        }
      } else {
        completion(.failure(NetworkingError.invalidResponseCode))
      }
    }.resume()
  }
}
