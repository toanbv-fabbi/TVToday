//
//  PopularsRootView.swift
//  PopularShows
//
//  Created by Jeans Ruiz on 8/21/20.
//

import UIKit
import Combine
import Shared

class PopularsRootView: NiblessView {

  private let viewModel: PopularViewModelProtocol

  let tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .plain)
    tableView.registerCell(cellType: TVShowViewCell.self)
    tableView.rowHeight = UITableView.automaticDimension
    tableView.tableFooterView = UIView()
    tableView.contentInsetAdjustmentBehavior = .automatic
    return tableView
  }()

  typealias DataSource = UITableViewDiffableDataSource<SectionPopularView, TVShowCellViewModel>
  typealias Snapshot = NSDiffableDataSourceSnapshot<SectionPopularView, TVShowCellViewModel>
  private var dataSource: DataSource?

  private var disposeBag = Set<AnyCancellable>()

  // MARK: - Initializer
  init(frame: CGRect = .zero, viewModel: PopularViewModelProtocol) {
    self.viewModel = viewModel
    super.init(frame: frame)

    addSubview(tableView)
    setupUI()
  }

  func stopRefresh() {
    tableView.refreshControl?.endRefreshing(with: 0.5)
  }

  private func setupUI() {
    setupTableView()
    setupDataSource()
    subscribe()
  }

  // MARK: - Setup TableView
  private func setupTableView() {
    tableView.registerCell(cellType: TVShowViewCell.self)
    tableView.delegate = self
    tableView.refreshControl = DefaultRefreshControl(refreshHandler: { [weak self] in
      self?.viewModel.refreshView()
    })
  }

  private func setupDataSource() {
    dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { [weak self] tableView, indexPath, model in
      let cell = tableView.dequeueReusableCell(with: TVShowViewCell.self, for: indexPath)
      cell.setModel(viewModel: model)

      // MARK: - TODO, use willDisplay instead
      if let totalItems = self?.dataSource?.snapshot().itemIdentifiers(inSection: .list).count, indexPath.row == totalItems - 1 {
        self?.viewModel.didLoadNextPage()
      }
      return cell
    })
  }

  private func subscribe() {
    viewModel
      .viewStateObservableSubject
      .map { viewState -> Snapshot in
        var snapShot = Snapshot()
        snapShot.appendSections([.list])
        snapShot.appendItems(viewState.currentEntities, toSection: .list)
        return snapShot
      }
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] snapshot in
        self?.dataSource?.apply(snapshot)
      })
      .store(in: &disposeBag)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    tableView.frame = bounds
  }
}

// MARK: - UITableViewDelegate
extension PopularsRootView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 175.0
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    viewModel.showIsPicked(index: indexPath.row)
  }
}
