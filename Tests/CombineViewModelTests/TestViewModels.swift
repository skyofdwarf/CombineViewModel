//
//  TestViewModels.swift
//  CombineViewModelTests
//
//  Created by YEONGJUNG KIM on 2022/01/16.
//

import Foundation
import Combine

@testable import CombineViewModel

struct Dependency {
    var games: [Game]
    var fruits: [Fruit]
}

final class StateViewModel: ViewModel<HappyAction, HappyMutation, HappyEvent, HappyState> {
    let dependency: Dependency
    init(dependency: Dependency,
         state initialState: HappyState,
         actionMiddlewares: [ActionMiddleware] = [],
         mutationMiddlewares: [MutationMiddleware] = [],
         eventMiddlewares: [EventMiddleware] = [],
         statePostwares: [StatePostware] = [])
    {
        self.dependency = dependency
        super.init(state: initialState,
                   actionMiddlewares: actionMiddlewares,
                   mutationMiddlewares: mutationMiddlewares,
                   eventMiddlewares: eventMiddlewares,
                   statePostwares: statePostwares)
    }
    
    override func react(action: Action, state: State) throws -> any Publisher<Reaction, Never> {
        switch action {
        case .wakeup:
            return [Reaction]([.mutation(.status(.idle)),
                             .mutation(.ready(dependency.games, dependency.fruits))])
            .publisher
            
        case .play(let game):
            return [Reaction]([ Reaction.mutation(.status(.playing(game))),
                                .event(.win(game)) ])
            .publisher
            
        case .eat(let fruit):
            return Just(.mutation(.status(.eating(fruit))))
            
        case .shout(let message):
            return Just(.mutation(.lastMessage(message)))
            
        case .sleep(let seconds):
            return Just(Reaction.action(.wakeup))
                .delay(for: .seconds(seconds), scheduler: RunLoop.main)
                .prepend(.mutation(.status(.sleeping)))
        }
    }
    
    override func reduce(mutation: Mutation, state: State) -> State {
        var state = state
        switch mutation {
        case .lastMessage(let text):
            state.lastMessage = text
            state.count += 1
            
        case let .ready(games, fruits):
            state.games = games
            state.fruits = fruits
            state.count += 1
            
        case let .status(status):
            state.status = status
            state.count += 1
        }
        
        return state
    }
}

final class DrivingStateViewModel: ViewModel<HappyAction, HappyMutation, HappyEvent, DrivingHappyState> {
    let dependency: Dependency
    init(dependency: Dependency, state initialState: DrivingHappyState) {
        self.dependency = dependency
        super.init(state: initialState)
    }
    
    override func react(action: Action, state: State) throws -> any Publisher<Reaction, Never> {
        switch action {
        case .wakeup:
            return [Reaction]([.mutation(.status(.idle)),
                               .mutation(.ready(dependency.games, dependency.fruits))])
            .publisher
            
        case .play(let game):
            return [Reaction]([ .mutation(.status(.playing(game))),
                           .event(.win(game)) ])
            .publisher
            
        case .eat(let fruit):
            return Just(.mutation(.status(.eating(fruit))))
            
        case .shout(let message):
            return Just(.mutation(.lastMessage(message)))
        
        case .sleep(let seconds):
            return Just(Reaction.action(.wakeup))
                .delay(for: .seconds(seconds), scheduler: RunLoop.main)
                .prepend(.mutation(.status(.sleeping)))
        }
    }
    
    override func reduce(mutation: Mutation, state: State) -> State {
        var state = state
        switch mutation {
        case .lastMessage(let text):
            state.lastMessage = text
            state.count += 1
            
        case let .ready(games, fruits):
            state.games = games
            state.fruits = fruits
            state.count += 1
            
        case let .status(status):
            state.status = status
            state.count += 1
        }
        
        return state
    }
}

final class ErrorViewModel: ViewModel<HappyAction, HappyMutation, HappyEvent, HappyState> {
    init() {
        super.init(state: HappyState())
    }
    
    override func react(action: Action, state: State) throws -> any Publisher<Reaction, Never> {
        let error = NSError(domain: "TestDomain", code: 3, userInfo: nil)
        throw error
    }
    
    override func reduce(mutation: Mutation, state: State) -> State {
        return state
    }
}

final class DelegateViewModel: ViewModel<HappyAction, HappyMutation, HappyEvent, DrivingHappyState> {
    init() {
        super.init(state: DrivingHappyState())
    }
    
    override func react(action: Action, state: State) throws -> any Publisher<Reaction, Never> {
        switch action {
        case .wakeup:
            return Just(.mutation(.status(.sleeping)))
        default:
            return Empty()
        }
    }
    
    override func reduce(mutation: Mutation, state: State) -> State {
        var state = state
        switch mutation {
        case let .status(status):
            state.status = status
            state.count += 1
        default:
            break
        }
        
        return state
    }
}

final class DelegatingViewModel: ViewModel<HappyAction, HappyMutation, HappyEvent, DrivingHappyState> {
    let delegate = DelegateViewModel()
    let actionRelay = PassthroughSubject<DelegateViewModel.Action, Never>()
    
    init() {
        super.init(state: DrivingHappyState())
        
        actionRelay
            .subscribe(delegate.action)
    }
    
    override func react(action: Action, state: State) throws -> any Publisher<Reaction, Never> {
        switch action {
        case .wakeup:
            actionRelay.send(.wakeup)
        default:
            break
        }
        
        return Empty()
    }
    
    override func reduce(mutation: Mutation, state: State) -> State {
        var state = state
        switch mutation {
        case let .status(status):
            state.status = status
            state.count += 1
        default:
            break
        }
        
        return state
    }
    
    override func transform(mutation: AnyPublisher<Mutation, Never>) -> any Publisher<Mutation, Never> {
        mutation.merge(with: delegate.$state.$status.map { Mutation.status($0) })
    }
}
