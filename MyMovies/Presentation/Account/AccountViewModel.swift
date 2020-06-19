//
//  AccountViewModel.swift
//  TVToday
//
//  Created by Jeans Ruiz on 6/19/20.
//  Copyright © 2020 Jeans. All rights reserved.
//

import Foundation
import RxFlow
import RxRelay

final class AccountViewModel {
  
  var steps = PublishRelay<Step>()
  
  var input: Input
  
  var output: Output
  
  // MARK: - Initializers
  
  init() {
    input = Input()
    output = Output()
  }
  
}

extension AccountViewModel: BaseViewModel {
  
  public struct Input { }
  
  public struct Output { }
}

extension AccountViewModel {
  
  public func navigateTo(step: Step) {
    steps.accept(step)
  }
}
