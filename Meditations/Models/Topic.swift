//
// Topic.swift
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

import UIKit.UIColor

// MARK: Topic

public struct Topic {
  var uuid: UUID
  var title: String
  var subtitle: String
  var description: String
  var featured: Bool
  var position: Int
  var color: UIColor?
  var subtopics: [Subtopic] = []
  var meditationUuids: [UUID]
  var meditations: [Meditation] = []
}

extension Topic: Decodable {

  enum CodingKeys: String, CodingKey {
    case hexColorString = "color"
    case description
    case shortDescription = "description_short"
    case featured
    case imageUrlString = "image_url"
    case meditationUuidStrings = "meditations"
    case parentUuidString = "parent_uuid"
    case position
    case thumbnailUrlString = "thumbnail_url"
    case title
    case uuidString = "uuid"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let hexColorString = try? container.decode(String.self, forKey: CodingKeys.hexColorString)
    let description = try container.decode(String.self, forKey: CodingKeys.description)
    _ = try? container.decode(String.self, forKey: CodingKeys.shortDescription)
    let featured = try container.decode(Bool.self, forKey: CodingKeys.featured)
    let position = try container.decode(Int.self, forKey: CodingKeys.position)
    let title = try container.decode(String.self, forKey: CodingKeys.title)
    _ = try? container.decode(String.self, forKey: CodingKeys.imageUrlString)
    let meditationUuidStrings = try container.decode([String].self, forKey: CodingKeys.meditationUuidStrings)
    let parentUuuidString = try? container.decode(String.self, forKey: CodingKeys.parentUuidString)
    _ = try? container.decode(String.self, forKey: CodingKeys.thumbnailUrlString)
    let uuidString = try container.decode(String.self, forKey: CodingKeys.uuidString)

    guard parentUuuidString == nil else {
      // Topics must not have a parent UUID
      throw DecodingError.invalidParentUuid
    }
    guard let uuid = UUID(uuidString: uuidString) else {
      throw DecodingError.invalidUuid
    }
    self.uuid = uuid
    self.featured = featured
    self.position = position
    self.color = UIColor(hex: hexColorString ?? "")
    self.title = title
    self.subtitle = String(format: "%d Meditations", meditationUuidStrings.count)
    self.description = description
    self.meditationUuids = meditationUuidStrings
      .compactMap { UUID(uuidString: $0) }
  }
}

// MARK: Featured Topics

public struct FeaturedTopics {
  let topics: [Topic]
}

extension FeaturedTopics: Decodable {

  enum CodingKeys: String, CodingKey {
    case topics
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    guard let topics = try? container.decode([FailableDecodable<Topic>].self, forKey: CodingKeys.topics) else {
      throw DecodingError.invalidTopic
    }
    guard let subtopics = try? container.decode([FailableDecodable<Subtopic>].self, forKey: CodingKeys.topics) else {
      throw DecodingError.invalidSubtopic
    }

    let builder = FeaturedTopicsBuilder()
    let director = TopicsDirector(withBuilder: builder)
    director.construct(topics: topics.compactMap({ $0.decoded }), withSubtopics: subtopics.compactMap({ $0.decoded }))
    self.topics = builder.getTopics()
  }
}
