//
//  AppState.swift
//  ComplexUserRegistration
//
//

import Combine

@dynamicMemberLookup
final class AppState {
    @Published var registrationInformation: RegistrationInformation = .initial
    @Published var step: Step = .userName

    subscript<A>(dynamicMember keyPath: WritableKeyPath<RegistrationInformation, A>) -> A {
        get { self.registrationInformation[keyPath: keyPath] }
        set { self.registrationInformation[keyPath: keyPath] = newValue }
    }

    subscript<A>(dynamicMember keyPath: WritableKeyPath<Address, A>) -> A {
        get { self.registrationInformation.address[keyPath: keyPath] }
        set { self.registrationInformation.address[keyPath: keyPath] = newValue }
    }
}
