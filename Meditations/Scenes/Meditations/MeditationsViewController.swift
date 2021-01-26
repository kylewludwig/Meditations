//
// MeditationsViewController.swift
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

protocol MeditationsDisplayLogic: class {
  var displayedTopic: Topic? { get }
  func displayFetchedMeditations(viewModel: Meditations.FetchMeditations.ViewModel)
  func displayFailureAlert(_ title: String, message: String?)
}

class MeditationsViewController: UITableViewController, MeditationsDisplayLogic {

  var interactor: MeditationsBusinessLogic?
  var router: (NSObjectProtocol & MeditationsRoutingLogic & MeditationsDataPassing)?

  private let reuseIdentifier = "MeditationsTableViewCellReuseIdentifier"

  // MARK: Object lifecycle
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  // MARK: Setup
  
  private func setup() {
    let viewController = self
    let interactor = MeditationsInteractor()
    let presenter = MeditationsPresenter()
    let router = MeditationsRouter()
    viewController.interactor = interactor
    viewController.router = router
    interactor.presenter = presenter
    presenter.viewController = viewController
    router.viewController = viewController
    router.dataStore = interactor
  }
  
  // MARK: Routing
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let scene = segue.identifier {
      let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
      if let router = router, router.responds(to: selector) {
        router.perform(selector, with: segue)
      }
    }
  }
  
  // MARK: View lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    // Add activity indicator
    self.view.addSubview(self.activityIndicator)
    let navBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0 +
      navigationController!.navigationBar.frame.height
    _ = self.activityIndicator.anchor(centerXAnchor: self.tableView.centerXAnchor,
                                      centerYAnchor: self.tableView.centerYAnchor,
                                      topConstant: navBarHeight)

    // Setup custom backBarButtonItem (with a workaround using a leftBarButtonItem instead)
    let image = UIImage(systemName: "arrow.left")!.withRenderingMode(.alwaysTemplate)
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image,
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(popViewController))

    self.tableView.register(MeditationsTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)

    self.fetchMeditations()
  }

  // MARK: UIViews

  private lazy var activityIndicator: UIActivityIndicatorView = {
    $0.hidesWhenStopped = true
    return $0
  }(UIActivityIndicatorView(style: .large))

  private lazy var descriptionLabel: InsetLabel = {
    $0.contentInsets = UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 15)
    $0.textAlignment = .left
    $0.lineBreakMode = .byWordWrapping
    $0.numberOfLines = 0
    return $0
  }(InsetLabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 88)))
  
  // MARK: Display logic

  var displayedTopic: Topic? {
    didSet {
      if let displayedTopic = displayedTopic {
        self.title = displayedTopic.title
        self.descriptionLabel.text = displayedTopic.description
      } else {
        self.title = nil
        self.descriptionLabel.text = nil
      }
      // Force tableHeaderView to update to new label size
      self.descriptionLabel.sizeToFit()
      self.tableView.tableHeaderView = descriptionLabel
    }
  }

  // TODO: Remove this once leftBarButttonItem workaround is fixed to use backBarButtonItem
  @objc func popViewController() {
    self.navigationController?.popViewController(animated: true)
  }

  func fetchMeditations() {
    self.activityIndicator.startAnimating()

    DispatchQueue.global(qos: .userInteractive).async {
      let request = Meditations.FetchMeditations.Request()
      self.interactor?.fetchMeditations(request: request)
    }
  }
  
  func displayFetchedMeditations(viewModel: Meditations.FetchMeditations.ViewModel) {
    let topic = viewModel.topic
    self.displayedTopic = topic

    self.activityIndicator.stopAnimating()

    guard !topic.meditations.isEmpty || topic.subtopics.allSatisfy({ !$0.meditations.isEmpty }) else {
      let title = "Uh oh! This page is self-guided right now"
      let message = "Please let us know and we'll fix it soon."
      self.displayFailureAlert(title, message: message)
      return
    }
    UIView.transition(with: tableView, duration: 0.5, options: .transitionCrossDissolve, animations: {
      self.tableView.reloadData()
    }, completion: nil)
  }

  func displayFailureAlert(_ title: String, message: String?) {
    guard self.presentedViewController == nil else { return }
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(okAction)
    self.present(alert, animated: true, completion: nil)
  }

  // MARK: UITableView delegate

  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 39.0
  }

  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let displayedTopic = displayedTopic else {
      return UIView()
    }

    // Set the title for each subtopic or a default for the main topic
    let sectionTitle = displayedTopic.subtopics.count == section ?
      "Meditations" :
      displayedTopic.subtopics[section].title

    // Create section label
    let label: UILabel = {
      $0.text = sectionTitle
      $0.textColor = .label
      $0.font = .systemFont(ofSize: 20.0)
      return $0
    }(UILabel())

    return {
      $0.backgroundColor = self.tableView.backgroundColor
      $0.addSubview(label)
      _ = label.anchor(top: $0.topAnchor,
                       left: $0.leftAnchor,
                       bottom: $0.bottomAnchor,
                       right: $0.rightAnchor,
                       topConstant: 0,
                       leftConstant: 15,
                       bottomConstant: 0,
                       rightConstant: 15)
      return $0
    }(UIView(frame: CGRect(x: 0, y: 0, width: label.frame.width, height: label.frame.height)))
  }

  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 32.0
  }

  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return {
      $0.backgroundColor = self.tableView.backgroundColor
      return $0
    }(UIView())
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 64.0
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }

  // MARK: UITableView datasource

  override func numberOfSections(in tableView: UITableView) -> Int {
    guard let displayedTopic = displayedTopic else {
      return 0
    }
    let additionalSection: Int = displayedTopic.meditations.isEmpty ? 0 : 1
    return displayedTopic.subtopics.count + additionalSection
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let displayedTopic = displayedTopic else {
      return 0
    }

    // Display number meditations for each subtopics or the displayed topic
    return displayedTopic.subtopics.count == section ?
      displayedTopic.meditations.count :
      displayedTopic.subtopics[section].meditations.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MeditationsTableViewCell
    
    guard let displayedTopic = displayedTopic else {
      return cell
    }

    // Override background color
    cell.backgroundColor = tableView.backgroundColor

    // Display meditations for each subtopics or the displayed topic
    let displayedMeditation = displayedTopic.subtopics.count == indexPath.section ?
      displayedTopic.meditations[indexPath.row] :
      displayedTopic.subtopics[indexPath.section].meditations[indexPath.row]

    cell.displayedMeditation = displayedMeditation

    return cell
  }
}
