//
// TopicsBuilder.swift
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

import Foundation.NSUUID

// MARK: Topics builder protocol

public protocol TopicsBuilder {
  var topics: [UUID: Topic] { get set }

  mutating func build(topics: [Topic], withSubtopics subtopics: [Subtopic]) throws
  func getTopics() -> [Topic]
}

public extension TopicsBuilder {

  mutating func build(topics: [Topic], withSubtopics subtopics: [Subtopic]) throws {
    if topics.isEmpty || subtopics.isEmpty {
      throw DecodingError.noData
    }

    self.topics = topics
      .reduce(into: [UUID: Topic]()) { $0[$1.uuid] = $1 }
    
    for subtopic in subtopics {
      // Add subtopic to each topic
      self.topics[subtopic.parentUuid]?.subtopics.append(subtopic)

      // Correct Topic subtitle to include combined number of Meditations in Topic and all Subtopics
      var totalMeditations = 0
      if let topic = self.topics[subtopic.parentUuid] {
        for subtopic in topic.subtopics {
          for _ in subtopic.meditationUuids {
            totalMeditations += 1
          }
        }
      }
      totalMeditations += self.topics[subtopic.parentUuid]?.meditationUuids.count ?? 0
      self.topics[subtopic.parentUuid]?.subtitle = String(format: "%d Meditations", totalMeditations)
    }
  }

  func getTopics() -> [Topic] {
    return self.topics.enumerated()
      .map { _, entry in return entry.value }
      .filter({ $0.featured })
      .sorted(by: { $0.position < $1.position })
  }
}

// MARK: Featured topics builder

class FeaturedTopicsBuilder: TopicsBuilder {
  var topics: [UUID: Topic] = [:]

  init() { }
}

// MARK: Topics director

class TopicsDirector {
  private var builder: TopicsBuilder?

  init(withBuilder builder: TopicsBuilder) {
    self.builder = builder
  }

  func construct(topics: [Topic], withSubtopics subtopics: [Subtopic]) {
    try? builder?.build(topics: topics, withSubtopics: subtopics)
  }
}
