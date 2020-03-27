//
//  LoadingView.swift
//  TVToday
//
//  Created by Jeans Ruiz on 3/26/20.
//  Copyright © 2020 Jeans. All rights reserved.
//

import UIKit

class LoadingView: UIView {
  
  let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupView()
  }
  
  func setupView() {
    backgroundColor = .white
    activityIndicator.color = .darkGray
    
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    addSubview(activityIndicator)
    
    activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    
    activityIndicator.startAnimating()
  }
}
