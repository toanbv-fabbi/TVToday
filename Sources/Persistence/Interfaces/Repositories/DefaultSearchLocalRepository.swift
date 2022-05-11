//
//  DefaultSearchLocalRepository.swift
//  
//
//  Created by Jeans Ruiz on 11/05/22.
//

import Combine
import Shared

public final class DefaultSearchLocalRepository {
  private let dataSource: SearchLocalDataSource
  private let loggedUserRepository: LoggedUserRepositoryProtocol

  public init(dataSource: SearchLocalDataSource, loggedUserRepository: LoggedUserRepositoryProtocol) {
    self.dataSource = dataSource
    self.loggedUserRepository = loggedUserRepository
  }
}

extension DefaultSearchLocalRepository: SearchLocalRepository {
  public func saveSearch(query: String) -> AnyPublisher<Void, CustomError> {
    let userId = loggedUserRepository.getUser()?.id ?? 0
    return dataSource.saveSearch(query: query, userId: userId)
  }

  public func fetchRecentSearches() -> AnyPublisher<[Search], CustomError> {
    let userId = loggedUserRepository.getUser()?.id ?? 0
    return dataSource.fetchRecentSearches(userId: userId)
      .map {
        return $0.map { Search(query: $0.query) }
      }
      .eraseToAnyPublisher()
  }
}
