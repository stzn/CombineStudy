//
//  PasswordView.swift
//  ComplexUserRegistration
//
//

import Combine
import SwiftUI

struct PasswordView: View {
    @ObservedObject var state: AppState

    var password: Binding<Password> {
        state.binding(
            get: \.password,
            set: { state[keyPath: \AppState.password] = $0 }
        )
    }

    var passwordConfirm: Binding<Password> {
        state.binding(
            get: \.passwordConfirm,
            set: { state.passwordConfirm = $0 }
        )
    }

    var body: some View {
        VStack(alignment: .center) {
            Text("パスワードを入力してください")
            SecureField("パスワード", text: password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.alphabet)
                .padding()
            SecureField("パスワード確認", text: passwordConfirm)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.alphabet)
                .padding()
            Spacer()
        }
    }
}

struct PasswordView_Previews: PreviewProvider {
    static var previews: some View {
        return PasswordView(state: AppState())
    }
}

