//
// Meditation.swift
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

import UIKit.UIImage

public struct Meditation {
  let uuid: UUID
  let title: String
  let teacherName: String
  let playCount: Int
  let imageUrlString: String
}

extension Meditation: Decodable {

  enum CodingKeys: String, CodingKey {
    case backgroundImageUrlString = "background_image_url"
    case description
    case featuredPosition = "featured_position"
    case free
    case imageUrlString = "image_url"
    case meditationOfTheDayDate = "meditation_of_the_day_date"
    case meditationOfTheDayDescription = "meditation_of_the_day_description"
    case newUntil = "new_until"
    case playCount = "play_count"
    case position
    case releaseDate = "release_date"
    case searchTags = "search_tags"
    case sections
    case startSeconds = "start_second"
    case teacherName = "teacher_name"
    case teacherUuidString = "teacher_uuid"
    case timerShouldCountDown = "timer_should_count_down"
    case title
    case uuidString = "uuid"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    _ = try? container.decode(String.self, forKey: CodingKeys.backgroundImageUrlString)
    _ = try container.decode(String.self, forKey: CodingKeys.description)
    _ = try? container.decode(Int.self, forKey: CodingKeys.featuredPosition)
    _ = try container.decode(Bool.self, forKey: CodingKeys.free)
    let imageUrlString = try container.decode(String.self, forKey: CodingKeys.imageUrlString)
    //_ = try? container.decode(Date.self, forKey: CodingKeys.meditationOfTheDayDate) // "04/08/2021"
    _ = try? container.decode(String.self, forKey: CodingKeys.meditationOfTheDayDescription)
    //_ = try? container.decode(Date.self, forKey: CodingKeys.newUntil) // "2019-06-02T21:19:00Z"
    let playCount = try container.decode(Int.self, forKey: CodingKeys.playCount)
    _ = try container.decode(Int.self, forKey: CodingKeys.position)
    //_ = try container.decode(Date.self, forKey: CodingKeys.releaseDate) // "05/03/2019"
    _ = try container.decode([SearchTag].self, forKey: CodingKeys.searchTags)
    let sectionContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .startSeconds)
    _ = try? sectionContainer?.decode([Int].self, forKey: CodingKeys.sections)
    let teacherName = try container.decode(String.self, forKey: CodingKeys.teacherName)
    _ = try container.decode(String.self, forKey: CodingKeys.teacherUuidString)
    _ = try container.decode(Bool.self, forKey: CodingKeys.timerShouldCountDown)
    let title = try container.decode(String.self, forKey: CodingKeys.title)
    let uuidString = try container.decode(String.self, forKey: CodingKeys.uuidString)

    guard let uuid = UUID(uuidString: uuidString) else {
      throw DecodingError.invalidUuid
    }
    self.uuid = uuid
    self.title = title
    self.teacherName = teacherName
    self.playCount = playCount
    self.imageUrlString = imageUrlString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
  }
}

// MARK: All meditations

struct AllMeditations {
  let meditations: [Meditation]
}

extension AllMeditations: Decodable {

  enum CodingKeys: String, CodingKey {
    case meditations
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let meditations = try? container.decode([FailableDecodable<Meditation>].self, forKey: CodingKeys.meditations)
    
    self.meditations = meditations?
      .compactMap { $0.decoded }
      ?? []
  }
}

// MARK: Search tag

struct SearchTag {
  let relatedTerms: [String]
  let title: String
}

extension SearchTag: Decodable {

  enum CodingKeys: String, CodingKey {
    case relatedTerms = "related_terms"
    case title
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let relatedTerms = try container.decode([String].self, forKey: CodingKeys.relatedTerms)
    let title = try container.decode(String.self, forKey: CodingKeys.title)

    self.relatedTerms = relatedTerms
    self.title = title
  }
}
