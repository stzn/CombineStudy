//
//  AppState.swift
//  ComplexUserRegistration
//
//

import Combine
import SwiftUI

@dynamicMemberLookup
final class AppState: ObservableObject {
    @Published var registrationInformation: RegistrationInformation = .initial
    @Published var step: Step = .userName

    @Published var passwordConfirm: String = ""

    subscript<A>(dynamicMember keyPath: WritableKeyPath<RegistrationInformation, A>) -> A {
        get { self.registrationInformation[keyPath: keyPath] }
        set { self.registrationInformation[keyPath: keyPath] = newValue }
    }

    subscript<A>(dynamicMember keyPath: WritableKeyPath<Address, A>) -> A {
        get { self.registrationInformation.address[keyPath: keyPath] }
        set { self.registrationInformation.address[keyPath: keyPath] = newValue }
    }

    func binding<Value>(
      get: @escaping (AppState) -> Value,
      set: @escaping (Value) -> Void
    ) -> Binding<Value> {
        Binding(get: { get(self) }, set: set)
    }
}
