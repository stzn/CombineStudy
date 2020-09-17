//
//  ComplexUserRegistrationApp.swift
//  ComplexUserRegistration
//
//

import Combine
import SwiftUI

@main
struct ComplexUserRegistrationApp: App {
    @StateObject var appState = AppState()
    private let client: ZipClient = .live

    @State private var restart: Bool = false

    var body: some Scene {
        WindowGroup {
            switch appState.step {
            case .userName:
                Navigation(state: appState,
                           content: userNameView,
                           title: "Step1",
                           previousStep: nil,
                           nextStep: .password,
                           nextButtonEnabled: userNameNextEnabled)
            case .password:
                Navigation(state: appState,
                           content: passwordView,
                           title: "Step2",
                           previousStep: .userName,
                           nextStep: .address,
                           nextButtonEnabled: passwordNextEnabled)
            case .address:
                Navigation(state: appState,
                           content: addressView,
                           title: "Step3",
                           previousStep: .password,
                           nextStep: .completion,
                           nextButtonEnabled: addressEnabled)
            case .completion:
                Navigation(state: appState,
                           content: completionView,
                           title: "登録完了",
                           previousStep: .address,
                           nextStep: nil,
                           nextButtonEnabled: false)
            }
        }.onChange(of: restart) { restart in
            if restart {
                appState.registrationInformation = .initial
                appState.step = .userName
            }
        }
    }

    private var userNameNextEnabled: Bool {
        !appState.userName.isEmpty
    }

    private var passwordNextEnabled: Bool {
        !appState.password.isEmpty
            && appState.password == appState.passwordConfirm
    }

    private var addressEnabled: Bool {
        !appState.address.zipcode.isEmpty
            && !appState.address.prefecture.isEmpty
            && !appState.address.city.isEmpty
            && !appState.address.other.isEmpty
    }

    private var userNameView: some View {
        UserNameView(state: appState)
    }

    private var passwordView: some View {
        PasswordView(state: appState)
    }

    private var addressView: some View {
        AddressView(state: appState,
                    client: client)
    }

    private var completionView: some View {
        CompletionView(restart: $restart,
                       state: appState)
    }
}

struct Navigation<Content: View>: View {
    @ObservedObject var state: AppState
    let content: Content
    let title: String
    let previousStep: Step?
    let nextStep: Step?
    let nextButtonEnabled: Bool

    var body: some View {
        NavigationView {
            content
            .padding()
            .navigationTitle(title)
            .navigationBarItems(
                leading: previousLink(for: previousStep),
                trailing: nextLink(for: nextStep)
                    .disabled(!nextButtonEnabled)
            )
        }
    }

    @ViewBuilder
    func previousLink(for step: Step?) -> some View {
        if let previous = step {
            Button("前へ") {
                state.step = previous
            }
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    func nextLink(for step: Step?) -> some View {
        if let next = step {
            Button("次へ") {
                state.step = next
            }
        } else {
            EmptyView()
        }
    }
}
