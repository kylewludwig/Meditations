//
// TopicsTableViewCell.swift
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

class TopicsTableViewCell: UITableViewCell {

  // MARK: Content

  var displayedTopic: Topic! {
    didSet {
      self.textLabel?.text = displayedTopic.title
      self.detailTextLabel?.text = displayedTopic.subtitle
      self.colorThumbnail.backgroundColor = displayedTopic.color
    }
  }

  // MARK: UIViews

  private let colorThumbnail: UIView = {
    $0.backgroundColor = .systemFill // default color
    return $0
  }(UIView())

  // MARK: View lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    setup()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    // Adjust border attributes
    self.layer.borderColor = UIColor.systemFill.cgColor
    self.layer.borderWidth = 1.0
    self.layer.cornerRadius = 3.0
  }

  // MARK: Setup

  private func setup() {
    // Adjust label attributes
    self.textLabel?.font = .boldSystemFont(ofSize: 18.0)
    self.textLabel?.textColor = .label
    self.detailTextLabel?.font = .systemFont(ofSize: 13.0)
    self.detailTextLabel?.textColor = .secondaryLabel

    // Adjust thumbnail contraints
    self.contentView.addSubview(colorThumbnail)
    _ = colorThumbnail.anchor(top: self.topAnchor,
                              left: self.leftAnchor,
                              bottom: self.bottomAnchor,
                              topConstant: 0,
                              leftConstant: 0,
                              bottomConstant: 0,
                              widthConstant: 12)
  }
}