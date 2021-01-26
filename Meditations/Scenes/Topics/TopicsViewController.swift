//
// TopicsViewController.swift
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

protocol TopicsDisplayLogic: class {
  var displayedTopics: [Topic] { get }
  func displayFetchedTopics(viewModel: Topics.FetchTopics.ViewModel)
  func displayFailureAlert(_ title: String, message: String?)
}

class TopicsViewController: UITableViewController, TopicsDisplayLogic {

  var interactor: TopicsBusinessLogic?
  var router: (NSObjectProtocol & TopicsRoutingLogic & TopicsDataPassing)?

  private let reuseIdentifier = "TopicsTableViewCellReuseIdentifier"
  
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
    let interactor = TopicsInteractor()
    let presenter = TopicsPresenter()
    let router = TopicsRouter()
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

    self.tableView.register(TopicsTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)

    // Add additional 10.0 margin to top of tableView
    self.tableView.tableHeaderView = {
      let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20.0)
      let view = UIView(frame: frame)
      return view
    }()

    self.fetchTopics()
  }

  // MARK: UIViews

  private lazy var activityIndicator: UIActivityIndicatorView = {
    $0.hidesWhenStopped = true
    return $0
  }(UIActivityIndicatorView(style: .large))

  // MARK: Display logic

  var displayedTopics = [Topic]()

  func fetchTopics() {
    self.activityIndicator.startAnimating()

    DispatchQueue.global(qos: .userInteractive).async {
      let request = Topics.FetchTopics.Request()
      self.interactor?.fetchTopics(request: request)
    }
  }

  func displayFetchedTopics(viewModel: Topics.FetchTopics.ViewModel) {
    self.activityIndicator.stopAnimating()

    if !viewModel.topics.isEmpty {
      self.displayedTopics = viewModel.topics
      // Animate reloading data
      UIView.transition(with: tableView, duration: 0.5, options: .transitionCrossDissolve, animations: {
        self.tableView.reloadData()
      }, completion: nil)
    } else {
      let title = "Sorry, we're out of topics"
      let message = "Try again soon!"
      self.displayFailureAlert(title, message: message)
    }
  }

  func displayFailureAlert(_ title: String, message: String?) {
    guard self.presentedViewController == nil else { return }
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(okAction)
    self.present(alert, animated: true, completion: nil)
  }

  // MARK: UITableView delegate
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    router?.routeToMeditations(segue: nil)
  }
  
  // MARK: UITableView datasource

  override func numberOfSections(in tableView: UITableView) -> Int {
    return self.displayedTopics.count
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! TopicsTableViewCell
    let displayedTopic = self.displayedTopics[indexPath.section]
    cell.displayedTopic = displayedTopic
    return cell
  }
}
