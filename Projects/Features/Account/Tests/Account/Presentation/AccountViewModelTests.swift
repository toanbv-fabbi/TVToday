//
//  AccountViewModelTests.swift
//  TVToday
//
//  Created by Jeans Ruiz on 6/19/20.
//  Copyright © 2020 Jeans. All rights reserved.
//

import Combine
import XCTest
@testable import Account
@testable import Shared

class AccountViewModelTests: XCTestCase {

  var sut: AccountViewModelProtocol!
  var createSessionUseCaseMock: CreateSessionUseCaseMock!
  var fetchAccountDetailsUseCaseMock: FetchAccountDetailsUseCaseMock!
  var fetchLoggedUserMock: FetchLoggedUserMock!
  var deleteLoguedUserUseCaseMock: DeleteLoguedUserUseCaseMock!
  private var disposeBag: Set<AnyCancellable>!

  override func setUp() {
    super.setUp()
    sut = nil
    createSessionUseCaseMock = CreateSessionUseCaseMock()
    fetchAccountDetailsUseCaseMock = FetchAccountDetailsUseCaseMock()
    fetchLoggedUserMock = FetchLoggedUserMock()
    deleteLoguedUserUseCaseMock = DeleteLoguedUserUseCaseMock()
    disposeBag = []
  }

  func test_When_Session_DoesNot_Exits_Should_Be_Login_State() {
    // given
    fetchLoggedUserMock.account = nil
    sut = AccountViewModel(createNewSession: createSessionUseCaseMock,
                           fetchAccountDetails: fetchAccountDetailsUseCaseMock,
                           fetchLoggedUser: fetchLoggedUserMock,
                           deleteLoguedUser: deleteLoguedUserUseCaseMock,
                           scheduler: .immediate)

    let expected = [AccountViewState.login]
    var received = [AccountViewState]()

    sut.viewState.removeDuplicates()
      .sink(receiveValue: { received.append($0) }).store(in: &disposeBag)

    // when
    sut.viewDidLoad()

    // then
    XCTAssertEqual(expected, received, "Should only receives one Value")
  }

  func test_When_Session_Exits_Should_Be_Profile_State() {
    // given
    fetchLoggedUserMock.account = AccountDomain(id: 1, sessionId: "1")
    fetchAccountDetailsUseCaseMock.result = AccountResult.stub()

    sut = AccountViewModel(createNewSession: createSessionUseCaseMock,
                           fetchAccountDetails: fetchAccountDetailsUseCaseMock,
                           fetchLoggedUser: fetchLoggedUserMock,
                           deleteLoguedUser: deleteLoguedUserUseCaseMock,
                           scheduler: .immediate)

    // when
    let expected = [
      AccountViewState.login,
      AccountViewState.profile(account: AccountResult.stub())
    ]
    var received = [AccountViewState]()

    sut.viewState.removeDuplicates()
      .sink(receiveValue: { received.append($0) }).store(in: &disposeBag)

    // when
    sut.viewDidLoad()

    // then
    XCTAssertEqual(expected, received, "Should receives two values")
  }

  func test_when_CreateSession_Returns_OK_ViewModel_Should_contains_Profile_State() {
    // given
    let authPermission = AuthPermissionViewModelMock()
    createSessionUseCaseMock.result = ()
    fetchAccountDetailsUseCaseMock.result = AccountResult.stub()

    sut = AccountViewModel(createNewSession: createSessionUseCaseMock,
                           fetchAccountDetails: fetchAccountDetailsUseCaseMock,
                           fetchLoggedUser: fetchLoggedUserMock,
                           deleteLoguedUser: deleteLoguedUserUseCaseMock,
                           scheduler: .immediate)
    authPermission.delegate = sut

    let expected = [
      AccountViewState.login,
      AccountViewState.profile(account: AccountResult.stub())
    ]
    var received = [AccountViewState]()

    sut.viewState.removeDuplicates()
      .sink(receiveValue: { received.append($0) }).store(in: &disposeBag)

    // when
    sut.viewDidLoad()
    authPermission.signIn()

    // then
    XCTAssertEqual(expected, received, "Should receives two values")
  }

  func test_when_CreateSession_Returns_Error_ViewModel_Should_contains_Login_State() {
    // given
    let authPermission = AuthPermissionViewModelMock()
    createSessionUseCaseMock.error = .noResponse
    fetchAccountDetailsUseCaseMock.result = AccountResult.stub()

    sut = AccountViewModel(createNewSession: createSessionUseCaseMock,
                           fetchAccountDetails: fetchAccountDetailsUseCaseMock,
                           fetchLoggedUser: fetchLoggedUserMock,
                           deleteLoguedUser: deleteLoguedUserUseCaseMock,
                           scheduler: .immediate)
    authPermission.delegate = sut

    let expected = [
      AccountViewState.login
    ]
    var received = [AccountViewState]()

    sut.viewState.removeDuplicates()
      .sink(receiveValue: { received.append($0) }).store(in: &disposeBag)

    // when
    sut.viewDidLoad()
    authPermission.signIn()

    // then
    XCTAssertEqual(expected, received, "Should receives two values")
  }
}
