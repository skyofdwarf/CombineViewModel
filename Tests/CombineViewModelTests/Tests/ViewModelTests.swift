//
//  CombineViewModelTests.swift
//  CombineViewModelTests
//
//  Created by YEONGJUNG KIM on 2022/01/14.
//

import XCTest
import Combine

@testable import CombineViewModel

class CombineViewModelTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_state() throws {
        let dependency = Dependency(games: [.lol, .wow], fruits: [.apple, .cherry])
        let state = HappyState(lastMessage: nil,
                               status: .idle,
                               games: [.lol],
                               fruits: [.apple])
        let vm = StateViewModel(dependency: dependency, state: state)
        
        XCTAssertEqual(vm.$state.lastMessage, nil)
        XCTAssertEqual(vm.$state.status, .idle)
                
        vm.send(action: .wakeup)
        XCTAssertEqual(vm.$state.games, dependency.games)
        XCTAssertEqual(vm.$state.fruits, dependency.fruits)
        XCTAssertEqual(vm.$state.count, 2)
        
        vm.send(action: .play(.wow))
        XCTAssertEqual(vm.$state.status, .playing(.wow))
        XCTAssertEqual(vm.$state.count, 3)
        
        vm.send(action: .eat(.cherry))
        XCTAssertEqual(vm.$state.status, .eating(.cherry))
        XCTAssertEqual(vm.$state.count, 4)
        
        vm.send(action: .eat(.apple))
        XCTAssertEqual(vm.$state.status, .eating(.apple))
        XCTAssertEqual(vm.$state.count, 5)
        
        let message_rock = "I wanna ROCK !"
                      
        vm.send(action: .shout(message_rock))
        XCTAssertEqual(vm.$state.lastMessage, message_rock)
        XCTAssertEqual(vm.$state.count, 6)
        
        XCTAssertEqual(vm.$state,
                       HappyState(lastMessage: message_rock,
                                  status: .eating(.apple),
                                  games: dependency.games,
                                  fruits: dependency.fruits,
                                  count: 6))
    }
    
    func test_state_drive() throws {
        var db = Set<AnyCancellable>()
        
        let dependency = Dependency(games: [.lol, .wow], fruits: [.apple, .cherry])
        let state = HappyState(lastMessage: nil,
                               status: .idle,
                               games: [.lol],
                               fruits: [.apple])
        let vm = StateViewModel(dependency: dependency, state: state)
        
        XCTAssertEqual(vm.$state.lastMessage, nil)
        XCTAssertEqual(vm.$state.status, .idle)
                
        func expect(_ tag: String, action: HappyAction) -> HappyState {
            var lastState: HappyState!
            
            let expectation = XCTestExpectation(description: tag)
            
            vm.state
                .sink {
                    lastState = $0
                    
                    expectation.fulfill()
                }
                .store(in: &db)
            
            vm.send(action: action)
            wait(for: [expectation], timeout: 1)
            
            return lastState
        }
        
        XCTAssertEqual(expect("wakeup", action: .wakeup),
                       HappyState(lastMessage: nil,
                                  status: .idle,
                                  games: dependency.games,
                                  fruits: dependency.fruits,
                                  count: 2))
        
        XCTAssertEqual(expect("play wow", action: .play(.wow)),
                       HappyState(lastMessage: nil,
                                  status: .playing(.wow),
                                  games: dependency.games,
                                  fruits: dependency.fruits,
                                  count: 3))
        
        XCTAssertEqual(expect("eat cherry", action: .eat(.cherry)),
                       HappyState(lastMessage: nil,
                                  status: .eating(.cherry),
                                  games: dependency.games,
                                  fruits: dependency.fruits,
                                  count: 4))
        
        XCTAssertEqual(expect("eat apple", action: .eat(.apple)),
                       HappyState(lastMessage: nil,
                                  status: .eating(.apple),
                                  games: dependency.games,
                                  fruits: dependency.fruits,
                                  count: 5))
        
        let message_rock = "I wanna ROCK !"
        
        
        XCTAssertEqual(expect("shout rock", action: .shout(message_rock)),
                       HappyState(lastMessage: message_rock,
                                  status: .eating(.apple),
                                  games: dependency.games,
                                  fruits: dependency.fruits,
                                  count: 6))
        
        XCTAssertEqual(expect("shout rock", action: .shout(message_rock)),
                       HappyState(lastMessage: message_rock,
                                  status: .eating(.apple),
                                  games: dependency.games,
                                  fruits: dependency.fruits,
                                  count: 7))
    }

    func test_driving_state() throws {
        let dependency = Dependency(games: [.lol, .wow], fruits: [.apple, .cherry])
        let state = DrivingHappyState(lastMessage: nil,
                                      status: .idle,
                                      games: [.lol],
                                      fruits: [.apple])
        let vm = DrivingStateViewModel(dependency: dependency, state: state)
        
        XCTAssertEqual(vm.$state.lastMessage, nil)
        XCTAssertEqual(vm.$state.status, .idle)

        vm.send(action: .wakeup)
        XCTAssertEqual(vm.$state.games, dependency.games)
        XCTAssertEqual(vm.$state.fruits, dependency.fruits)
        XCTAssertEqual(vm.$state.count, 2 /* status, ready */)

        vm.send(action: .play(.wow))
        XCTAssertEqual(vm.$state.status, .playing(.wow))
        XCTAssertEqual(vm.$state.count, 3)

        vm.send(action: .eat(.cherry))
        XCTAssertEqual(vm.$state.status, .eating(.cherry))
        XCTAssertEqual(vm.$state.count, 4)

        vm.send(action: .eat(.apple))
        XCTAssertEqual(vm.$state.status, .eating(.apple))
        XCTAssertEqual(vm.$state.count, 5)

        let message_rock = "I wanna ROCK !"

        vm.send(action: .shout(message_rock))
        XCTAssertEqual(vm.$state.lastMessage, message_rock)
        XCTAssertEqual(vm.$state.count, 6)

        XCTAssertEqual(vm.$state,
                       DrivingHappyState(lastMessage: message_rock,
                                         status: .eating(.apple),
                                         games: dependency.games,
                                         fruits: dependency.fruits,
                                         count: 6))
    }
    
    func test_driving_state_drive() throws {
        var db = Set<AnyCancellable>()
        
        let dependency = Dependency(games: [.lol, .wow], fruits: [.apple, .cherry])
        let state = DrivingHappyState(lastMessage: nil,
                                      status: .idle,
                                      games: [],
                                      fruits: [])
        let vm = DrivingStateViewModel(dependency: dependency, state: state)
        
        XCTAssertEqual(vm.$state,
                       DrivingHappyState(lastMessage: nil,
                                         status: .idle,
                                         games: [],
                                         fruits: [],
                                         count: 0))
        
        let status = XCTestExpectation(description: "status")
        let games = XCTestExpectation(description: "games")
        
        vm.send(action: .play(.sc))
        vm.send(action: .wakeup)
        
        vm.state
            .sink {
                if $0.status == .idle {
                    status.fulfill()
                }
                if $0.games == dependency.games {
                    games.fulfill()
                }
            }
            .store(in: &db)
        
        wait(for: [status, games], timeout: 3)
    }
    
    func test_driving_state_prop_drive() throws {
        var db = Set<AnyCancellable>()
        
        let dependency = Dependency(games: [.lol, .wow], fruits: [.apple, .cherry])
        let state = DrivingHappyState(lastMessage: nil,
                                      status: .idle,
                                      games: [],
                                      fruits: [])
        let vm = DrivingStateViewModel(dependency: dependency, state: state)
        
        XCTAssertEqual(vm.$state,
                       DrivingHappyState(lastMessage: nil,
                                         status: .idle,
                                         games: [],
                                         fruits: [],
                                         count: 0))
        
        let status = XCTestExpectation(description: "status")
        let games = XCTestExpectation(description: "games")
        
        vm.send(action: .play(.sc))
        
        vm.$state.$status
            .sink {
                if $0 == .playing(.sc) {
                    status.fulfill()
                }
            }
            .store(in: &db)
        
        vm.send(action: .wakeup)
        
        vm.$state.$games
            .sink {
                if $0 == dependency.games {
                    games.fulfill()
                }
            }.store(in: &db)
        
        wait(for: [status, games], timeout: 3)
    }
    
    func test_driving_state_event() throws {
        var db = Set<AnyCancellable>()
        
        let dependency = Dependency(games: [.lol, .wow], fruits: [.apple, .cherry])
        let state = DrivingHappyState(lastMessage: nil,
                                      status: .idle,
                                      games: [],
                                      fruits: [])
        let vm = DrivingStateViewModel(dependency: dependency, state: state)

        let event = XCTestExpectation(description: "event")
        vm.event
            .sink {
                XCTAssertEqual($0, .win(.sc))
                
                event.fulfill()
            }
            .store(in: &db)
        
        vm.send(action: .play(.sc))
        
        wait(for: [event], timeout: 5)
    }
    
    func test_action_by_reaction() throws {
        var rawActionHistory: [HappyAction] = []
        
        // nontyped logger
        let rawActionLogger: Middleware<HappyState, HappyAction> = nontyped_middleware { state, next, action in
            rawActionHistory.append(action)
            return next(action)
        }
        
        let dependency = Dependency(games: [.lol, .wow],
                                    fruits: [.apple, .cherry])
        let vm = StateViewModel(dependency: dependency,
                                state: HappyState(),
                                actionMiddlewares: [rawActionLogger])
        
        XCTAssertEqual(vm.$state.status, .idle)
        
        vm.send(action: .sleep(3))
        
        XCTAssertEqual(rawActionHistory.last, .sleep(3))
        XCTAssertEqual(vm.$state.status, .sleeping)
        
        _ = XCTWaiter.wait(for: [XCTestExpectation(description: "wakeup")], timeout: 4.0)
        
        XCTAssertEqual(rawActionHistory.last, .wakeup)
        XCTAssertEqual(vm.$state.status, .idle)
        XCTAssertEqual(vm.$state.games, dependency.games)
        XCTAssertEqual(vm.$state.fruits, dependency.fruits)
    }
    
    func test_action_logger() throws {
        var rawActionHistory: [HappyAction] = []
        
        // nontyped logger
        let rawActionLogger: Middleware<HappyState, HappyAction> = nontyped_middleware { state, next, action in
            rawActionHistory.append(action)
            return next(action)
        }
                
        let MSG_WAKEUP = "NO"
        let MSG_PLAY = "I'm Hungry"
        let MSG_EAT = "I'm FULL"
        let MSG_SHOUT = "RAW SHOUT"
        
        // typed logger
        let actionTransformer = StateViewModel.middleware.action { state, next, action in
            switch action {
            case .wakeup:
                return next(.shout(MSG_WAKEUP))
            case .play:
                return next(.shout(MSG_PLAY))
            case .eat:
                return next(.shout(MSG_EAT))
            case .shout(let msg):
                return next(.shout(msg))
            case .sleep(let seconds):
                return next(.sleep(seconds))
            }
        }
        
        let dependency = Dependency(games: [.lol, .wow],
                                    fruits: [.apple, .cherry])

        let vm = StateViewModel(dependency: dependency,
                                state: HappyState(),
                                actionMiddlewares: [rawActionLogger, actionTransformer])

        XCTAssertEqual(vm.$state.status, .idle)
        
        vm.send(action: .wakeup)
        
        XCTAssertEqual(rawActionHistory.last, .wakeup)
        XCTAssertEqual(vm.$state.status, .idle)
        XCTAssertEqual(vm.$state.lastMessage, MSG_WAKEUP)
        
        vm.send(action: .play(.lol))
        
        XCTAssertEqual(rawActionHistory.last, .play(.lol))
        XCTAssertEqual(vm.$state.status, .idle)
        XCTAssertEqual(vm.$state.lastMessage, MSG_PLAY)
        
        vm.send(action: .shout(MSG_SHOUT))
        
        XCTAssertEqual(rawActionHistory.last, .shout(MSG_SHOUT))
        XCTAssertEqual(vm.$state.status, .idle)
        XCTAssertEqual(vm.$state.lastMessage, MSG_SHOUT)
    }
    
    func test_action_ignore_logger() throws {
        var rawActionHistory: [HappyAction] = []
        
        // nontyped logger
        let rawActionLogger: Middleware<HappyState, HappyAction> = nontyped_middleware { state, next, action in
            rawActionHistory.append(action)
            return next(action)
        }
        
        // typed logger
        let actionIgnoring = StateViewModel.middleware.action { state, next, action in
            // dose not call next(action)
            return action
        }
        
        let dependency = Dependency(games: [.lol, .wow],
                                    fruits: [.apple, .cherry])
        let state = HappyState()
        
        let vm = StateViewModel(dependency: dependency,
                                state: state,
                                actionMiddlewares: [rawActionLogger, actionIgnoring])
        
        XCTAssertEqual(vm.$state.status, .idle)
        
        vm.send(action: .wakeup)
        
        XCTAssertEqual(rawActionHistory.last, .wakeup)
        XCTAssertEqual(vm.$state, state)
        
        vm.send(action: .play(.lol))
        
        XCTAssertEqual(rawActionHistory.last, .play(.lol))
        XCTAssertEqual(vm.$state, state)
        
        vm.send(action: .shout("HAH"))
        
        XCTAssertEqual(rawActionHistory.last, .shout("HAH"))
        XCTAssertEqual(vm.$state, state)
    }
    
    func test_mutation_logger() throws {
        var rawMutationHistory: [HappyMutation] = []
        
        // nontyped logger
        let rawMutationLogger: Middleware<HappyState, HappyMutation> = nontyped_middleware { state, next, mutation in
            rawMutationHistory.append(mutation)
            return next(mutation)
        }
                
        let MSG_OTHER = "I'm not ready"
        let MSG_SHOUT = "shooooout"
        
        // typed logger
        let mutationTransformer = StateViewModel.middleware.mutation { state, next, mutation in
            switch mutation {
            case .lastMessage:
                return next(mutation)
            default:
                return next(.lastMessage(MSG_OTHER))
            }
        }
        
        let dependency = Dependency(games: [.lol, .wow],
                                    fruits: [.apple, .cherry])
        let vm = StateViewModel(dependency: dependency,
                                state: HappyState(),
                                mutationMiddlewares: [rawMutationLogger, mutationTransformer])
        
        XCTAssertEqual(vm.$state.status, .idle)
        
        vm.send(action: .wakeup)
        
        XCTAssertEqual(rawMutationHistory.last, .ready(dependency.games, dependency.fruits))
        XCTAssertEqual(vm.$state.status, .idle)
        XCTAssertEqual(vm.$state.lastMessage, MSG_OTHER)
        
        vm.send(action: .play(.lol))
        
        XCTAssertEqual(rawMutationHistory.last, .status(.playing(.lol)))
        XCTAssertEqual(vm.$state.status, .idle)
        XCTAssertEqual(vm.$state.lastMessage, MSG_OTHER)
        
        vm.send(action: .shout(MSG_SHOUT))
        
        XCTAssertEqual(rawMutationHistory.last, .lastMessage(MSG_SHOUT))
        XCTAssertEqual(vm.$state.status, .idle)
        XCTAssertEqual(vm.$state.lastMessage, MSG_SHOUT)
    }
    
    func test_mutation_error() throws {
        var db = Set<AnyCancellable>()
        let vm = ErrorViewModel()
        
        let expectation = XCTestExpectation(description: "error")
        
        vm.error
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &db)
        
        vm.send(action: .wakeup)
        
        wait(for: [expectation], timeout: 2)
    }
    
    func test_transform_mutation() throws {
        let vm = DelegatingViewModel()
        
        let expectation = XCTestExpectation(description: "transform_mutation")
        
        XCTAssertEqual(vm.$state.status, HappyStatus.idle)
        XCTAssertEqual(vm.$state.count, 0)
        XCTAssertNil(vm.$state.lastMessage)
        
        vm.send(action: .wakeup)
        vm.send(action: .shout("no no"))
        
        _ = XCTWaiter.wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(vm.$state.status, HappyStatus.sleeping)
        XCTAssertEqual(vm.$state.count, 1)
        XCTAssertNil(vm.$state.lastMessage)
    }
}