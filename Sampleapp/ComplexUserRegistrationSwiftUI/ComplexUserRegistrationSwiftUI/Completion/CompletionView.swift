//
//  CompletionView.swift
//  ComplexUserRegistration
//
//

import SwiftUI

struct CompletionView: View {
    @Binding var restart: Bool
    @ObservedObject var state: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("ユーザー名:\n\(state.userName)")
            Text("パスワード:\n\(state.password)")
            Text("住所:\n\(state.address.displayed)")
            Button("最初から") { restart = true }
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.blue, lineWidth: 5))
                .animation(nil)
            Spacer()
        }
        .onDisappear { restart = false }
    }
}

struct CompletionView_Previews: PreviewProvider {
    static var previews: some View {
        let state = AppState()
        state.registrationInformation = .mock
        return CompletionView(restart: .constant(false),
                              state: state)
    }
}

extension Address {
    static let mock: Self = .init(zipcode: "11111111",
                                  prefecture: "東京都", city: "千代田区",
                                  other: "中央１−１−１")
}

extension RegistrationInformation {
    static let mock: Self = .init(userName: "Test", password: "password", address: .mock)
}
