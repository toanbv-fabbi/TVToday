//
//  AiringTodayViewModel.swift
//  
//
//  Created by Jeans Ruiz on 1/05/22.
//

import Combine
import CombineSchedulers
import NetworkingInterface
import Shared

func mapTVShow2IntoTVShow(_ show: TVShowPage.TVShow) -> TVShow {
  // MARK: - TODO, Remove this
  return TVShow(id: show.id,
                name: show.name,
                voteAverage: show.voteAverage,
                firstAirDate: show.firstAirDate,
                posterPath: show.posterPath?.absoluteString ?? "",
                genreIds: show.genreIds,
                backDropPath: show.backDropPath?.absoluteString ?? "",
                overview: show.overview,
                originCountry: [],
                voteCount: show.voteCount)
}

final class AiringTodayViewModel: AiringTodayViewModelProtocol {
  let fetchTVShowsUseCase: FetchTVShowsUseCase
  let viewStateObservableSubject = CurrentValueSubject<SimpleViewState<AiringTodayCollectionViewModel>, Never>(.loading)

  var shows: [TVShowPage.TVShow]
  var showsCells: [AiringTodayCollectionViewModel] = []

  let scheduler: AnySchedulerOf<DispatchQueue>
  private weak var coordinator: AiringTodayCoordinatorProtocol?
  var disposeBag = Set<AnyCancellable>()

  // MARK: - Initializers
  init(fetchTVShowsUseCase: FetchTVShowsUseCase,
       scheduler: AnySchedulerOf<DispatchQueue> = .main,
       coordinator: AiringTodayCoordinatorProtocol?) {
    self.fetchTVShowsUseCase = fetchTVShowsUseCase
    self.scheduler = scheduler
    self.coordinator = coordinator
    shows = []
  }

  private func mapToCell(entities: [TVShowPage.TVShow]) -> [AiringTodayCollectionViewModel] {
    return entities
      .map { mapTVShow2IntoTVShow($0) }
      .map { AiringTodayCollectionViewModel(show: $0) }
  }

  // MARK: Input
  func viewDidLoad() {
    getShows(for: 1)
  }

  func didLoadNextPage() {
    if case .paging(_, let nextPage) = viewStateObservableSubject.value {
      getShows(for: nextPage)
    }
  }

  func refreshView() {
    getShows(for: 1, showLoader: false)
  }

  func getCurrentViewState() -> SimpleViewState<AiringTodayCollectionViewModel> {
    return viewStateObservableSubject.value
  }

  func showIsPicked(with id: Int) {
    coordinator?.navigate(to: .showIsPicked(id))
  }

  // MARK: - Private
  private func getShows(for page: Int, showLoader: Bool = true) {

    if viewStateObservableSubject.value.isInitialPage, showLoader {
      viewStateObservableSubject.send(.loading)
    }

    let request = FetchTVShowsUseCaseRequestValue(page: page)

    fetchTVShowsUseCase.execute(requestValue: request)
      .receive(on: scheduler)
      .sink(receiveCompletion: { [weak self] completion in
        switch completion {
        case let .failure(error):
          self?.handleError(error)
        case .finished: break
        }
      }, receiveValue: { [weak self] result in
        self?.processFetched(for: result, currentPage: page)
      })
      .store(in: &disposeBag)
  }

  private func handleError(_ error: DataTransferError) {
    if viewStateObservableSubject.value.isInitialPage {
      viewStateObservableSubject.send(.error(error.localizedDescription))
    }
  }

  private func processFetched(for response: TVShowPage, currentPage: Int) {
    if currentPage == 1 {
      shows.removeAll()
    }

    let fetchedShows = response.showsList

    self.shows.append(contentsOf: fetchedShows)

    if self.shows.isEmpty {
      viewStateObservableSubject.send(.empty)
      return
    }

    let cellsShows = mapToCell(entities: shows)

    if response.hasMorePages {
      viewStateObservableSubject.send( .paging(cellsShows, next: response.nextPage) )
    } else {
      viewStateObservableSubject.send( .populated(cellsShows) )
    }
  }
}
