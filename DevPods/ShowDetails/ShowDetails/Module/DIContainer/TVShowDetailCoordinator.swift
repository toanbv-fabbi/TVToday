//
//  TVShowDetailCoordinator.swift
//  TVToday
//
//  Created by Jeans Ruiz on 4/7/20.
//  Copyright © 2020 Jeans. All rights reserved.
//

import UIKit
import Networking
import Shared
import Persistence

protocol TVShowDetailCoordinatorDependencies {
  
  func buildShowDetailsViewController(with showId: Int,
                                      coordinator: TVShowDetailCoordinatorProtocol?,
                                      closures: TVShowDetailViewModelClosures?) -> UIViewController
  
  func buildEpisodesViewController(with showId: Int) -> UIViewController
}

public protocol TVShowDetailCoordinatorProtocol: class {
  
  func navigate(to step: ShowDetailsStep)
}

public protocol TVShowDetailCoordinatorDelegate: class {
  
  func tvShowDetailCoordinatorDidFinish()
}

public class TVShowDetailCoordinator: NavigationCoordinator, TVShowDetailCoordinatorProtocol {
  
  public weak var delegate: TVShowDetailCoordinatorDelegate?
  
  public let navigationController: UINavigationController
  
  private let dependencies: TVShowDetailCoordinatorDependencies
  
  // MARK: - Life Cycle
  
  init(navigationController: UINavigationController,
       dependencies: TVShowDetailCoordinatorDependencies) {
    
    self.navigationController = navigationController
    self.dependencies = dependencies
  }
  
  deinit {
    print("deinit \(Self.self)")
  }
  
  public func start(with step: ShowDetailsStep) {
    navigate(to: step)
  }
  
  // MARK: - Navigation
  
  public func navigate(to step: ShowDetailsStep) {
    switch step {
    case .showDetailsIsRequired(let showId, let closures):
      showDetailsFeature(with: showId, closures: closures)
      
    case .seasonsAreRequired(let showId):
      navigateToSeasonsScreen(with: showId)
      
    case .detailViewDidFinish:
      delegate?.tvShowDetailCoordinatorDidFinish()
    }
  }
  
  // MARK: - Navigate to Show Details
  
  fileprivate func showDetailsFeature(with showId: Int, closures: TVShowDetailViewModelClosures? = nil) {
    let detailVC = dependencies.buildShowDetailsViewController(with: showId, coordinator: self, closures: closures)
    navigationController.pushViewController(detailVC, animated: true)
  }
  
  // MARK: - Navigate Seasons List
  
  fileprivate func navigateToSeasonsScreen(with showId: Int) {
    let seasonsVC = dependencies.buildEpisodesViewController(with: showId)
    navigationController.pushViewController(seasonsVC, animated: true)
  }
}

// MARK: - Steps

public enum ShowDetailsStep: Step {
  
  case
  
  showDetailsIsRequired(withId: Int, closures: TVShowDetailViewModelClosures? = nil),
  
  seasonsAreRequired(withId: Int),
  
  detailViewDidFinish
}
