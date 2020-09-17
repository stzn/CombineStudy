//
//  ContentView.swift
//  UserRegistrationCombineSwiftUI
//
//

import Combine
import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    var body: some View {
        ZStack(alignment: .center) {
            if viewModel.registerRequesting {
                registerLoadingView
            }
            Form {
                Section(header: Text("登録画面").font(.largeTitle)) {
                    idTextField
                    passwordTextField
                    passwordConfirmTextField
                    registerButton
                }
            }.alert(isPresented: $viewModel.isShowRegisterResult) {
                let title: String
                let message: String
                if viewModel.registerResult {
                    title = "成功"
                    message = "登録が完了しました"
                } else {
                    title = "失敗"
                    message = "もう一度お試しください"
                }
                return Alert(title: Text(title),
                             message: Text(message))
            }
        }
    }

    private var registerLoadingView: some View {
        Group {
            Color.gray.opacity(0.5)
                .overlay(ProgressView())
                .zIndex(2)
        }
    }

    private var idTextField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("ID:").font(.headline)
                Spacer()
                if viewModel.idValidatioRequesting {
                    ProgressView()
                } else {
                    validMark(viewModel.isIdValid)
                }
            }
            TextField("", text: $viewModel.id)
        }
    }

    private var passwordTextField: some View {
        VStack(alignment: .leading, spacing: 8)  {
            HStack {
                Text("パスワード:").font(.headline)
                Spacer()
                validMark(viewModel.isPasswordValid)
            }
            TextField("", text: $viewModel.password)
        }
    }

    private var passwordConfirmTextField: some View {
        VStack(alignment: .leading, spacing: 8)  {
            HStack {
                Text("パスワード確認:").font(.headline)
                Spacer()
                validMark(viewModel.isPasswordCofirmValid)
            }
            TextField("", text: $viewModel.passwordConfirm)
        }
    }

    private var registerButton: some View {
        Button {
            viewModel.register()
        }
        label: {
            Text("登録").font(.title2)
        }
        .disabled(!viewModel.isButtonEnabled)
        .frame(maxWidth: .infinity)
        .background(viewModel.isButtonEnabled ?
                        Color.blue : Color.gray)
        .cornerRadius(8)
        .foregroundColor(.white)
    }

    @ViewBuilder
    private func validMark(_ isValid: Bool) -> some View {
        if isValid {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        } else {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

final class ViewModel: ObservableObject {
    @Published var id = ""
    @Published var password = ""
    @Published var passwordConfirm = ""
    @Published var idValidatioRequesting = false
    @Published var registerRequesting = false
    @Published var isIdValid = false
    @Published var isPasswordValid = false
    @Published var isPasswordCofirmValid = false
    @Published var registerResult: Bool = false
    @Published var isShowRegisterResult: Bool = false

    private let api = DummyAPI()
    private var cancelable: AnyCancellable?

    var isButtonEnabled: Bool {
        isIdValid && isPasswordValid
            && isPasswordCofirmValid && !registerRequesting
    }

    init() {
        // ID欄の入力値を受け取り、APIリクエストを送り、結果をisIdValidに反映させている
        $id.dropFirst()
            .handleEvents(
                receiveOutput: { _ in self.idValidatioRequesting = true }) // インディケータ表示, registerButtonの押下不可
            .debounce(for: 1.0, scheduler: DispatchQueue.main) // 入力を1秒待つ
            .removeDuplicates() // 重複を避ける
            .flatMap(self.api.validateId) // APIリクエストを送る
            .receive(on: DispatchQueue.main) // Main Threadで処理を続ける
            .handleEvents(receiveOutput: { _ in self.idValidatioRequesting = false }) // インディケータ非表示, registerButtonの制御
            .assign(to: &$isIdValid) // APIリクエストの結果を通知

        $password
            .dropFirst()
            .map { $0.count > 5 } // パスワードのバリデーション
            .assign(to: &$isPasswordValid) // パスワードのバリデーション結果の通知

        $passwordConfirm
            .dropFirst()
            .combineLatest($password)
            .map { passwordText, confirmText in
                passwordText == confirmText && self.isPasswordValid
            }
            .assign(to: &$isPasswordCofirmValid)
    }

    func register() {
        registerRequesting = true
        cancelable = self.api.register()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.registerResult = result
                self?.isShowRegisterResult = true
                self?.registerRequesting = false
            }
    }
}

// MARK: - API

struct DummyAPI {
    func validateId(_ text: String) -> AnyPublisher<Bool, Never> {
        Deferred {
            Future { promise in
                DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                    promise(.success(text.count > 5))
                }
            }
        }.eraseToAnyPublisher()
    }

    func register() -> AnyPublisher<Bool, Never> {
        Deferred {
            Future { promise in
                DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                    promise(.success(Int.random(in: 0...1000).isMultiple(of: 2)))
                }
            }
        }.eraseToAnyPublisher()
    }
}
