//
// UIView.swift
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

import UIKit.UIView

// MARK: UIView anchor contraints

extension UIView {
  
  func anchor(centerXAnchor: NSLayoutXAxisAnchor? = nil, centerYAnchor: NSLayoutYAxisAnchor? = nil,
              top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil,
              bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0,
              leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0,
              widthConstant: CGFloat = 0, heightConstant: CGFloat = 0) -> [NSLayoutConstraint] {

    self.translatesAutoresizingMaskIntoConstraints = false
    var anchors = [NSLayoutConstraint]()

    if let centerXAnchor = centerXAnchor {
      if leftConstant != 0 {
        anchors.append(centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: leftConstant))
      } else if rightConstant != 0 {
        anchors.append(centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: -rightConstant))
      } else {
        anchors.append(centerXAnchor.constraint(equalTo: self.centerXAnchor))
      }
    } else {
      if let left = left {
        anchors.append(leftAnchor.constraint(equalTo: left, constant: leftConstant))
      }
      if let right = right {
        anchors.append(rightAnchor.constraint(equalTo: right, constant: -rightConstant))
      }
    }

    if let centerYAnchor = centerYAnchor {
      if topConstant != 0 {
        anchors.append(centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: topConstant))
      } else if bottomConstant != 0 {
        anchors.append(centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -bottomConstant))
      } else {
        anchors.append(centerYAnchor.constraint(equalTo: self.centerYAnchor))
      }
    } else {
      if let top = top {
        anchors.append(topAnchor.constraint(equalTo: top, constant: topConstant))
      }
      if let bottom = bottom {
        anchors.append(bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant))
      }
    }

    if widthConstant > 0 {
      anchors.append(widthAnchor.constraint(equalToConstant: widthConstant))
    }

    if heightConstant > 0 {
      anchors.append(heightAnchor.constraint(equalToConstant: heightConstant))
    }

    anchors.forEach({ $0.isActive = true })
    return anchors
  }
}