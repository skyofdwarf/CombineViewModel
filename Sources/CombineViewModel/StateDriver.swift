//
//  StateDriver.swift
//  CombineViewModel
//
//  Created by YEONGJUNG KIM on 2022/10/25.
//

import Combine

/// StateDriver is a wrapper to drive state or properties of the state.
///
/// You have 2 options to get new value of state. You should use one way for consistency.
///
/// 1. drive state to get a new state value.
///     ```
///     struct State {
///         let foo = 0
///         let bar = 1
///     }
///     vm.state
///         .sink { state in
///             print(state.foo)
///             print(state.bar)
///         }
///     ```
///
/// 2. drive property of state directly to get a new property value.
///     ```
///     struct State {
///         @Drived var foo = 0
///         @Drived var bar = 1
///     }
///     vm.$state.$foo
///         .sink { foo in
///             print(foo)
///         }
///     vm.$state.$bar
///         .sink { bar in
///             print(bar)
///         }
///     ```
///
/// To get current value of the state itself, prefix state with `$`.
/// ```
/// struct State {
///     @Drived var foo = 0
///     let bar = 1
/// }
/// vm.$state
/// vm.$state.foo
/// ```
//@dynamicMemberLookup
public struct StateDriver<Element> {
    internal let relay: CurrentValueSubject<Element, Never>
    
    public init (state: Element) {
        relay = CurrentValueSubject<Element, Never>(state)
    }    
}

extension StateDriver: Publisher {
    public typealias Output = Element
    public typealias Failure = Never
    
    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        relay.receive(subscriber: subscriber)
    }
}

extension StateDriver: CustomStringConvertible where Element: CustomStringConvertible {
    public var description: String { relay.value.description }
}

extension StateDriver: CustomDebugStringConvertible where Element: CustomDebugStringConvertible {
    public var debugDescription: String { relay.value.debugDescription }
}
