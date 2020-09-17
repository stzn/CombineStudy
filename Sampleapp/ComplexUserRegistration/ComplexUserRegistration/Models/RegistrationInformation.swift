//
//  RegistrationInformation.swift
//  ComplexUserRegistration
//
//

import Foundation

typealias UserName = String
typealias Password = String

struct RegistrationInformation {
    var userName: UserName
    var password: Password
    var address: Address

    static let initial: Self = .init(userName: "", password: "", address: .initial)
}

// MARK: - Address

struct Address {
    var zipcode: String
    var prefecture: String
    var city: String
    var other: String
    static let initial: Self = .init(zipcode: "", prefecture: "", city: "", other: "")
}

extension Address {
    var displayed: String {
        "\(zipcode)\n\(prefecture)\(city)\(other)"
    }
}
