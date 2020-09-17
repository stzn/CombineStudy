//
//  UserNameView.swift
//  ComplexUserRegistration
//
//

import Combine
import SwiftUI

struct UserNameView: View {
    @ObservedObject var state: AppState

    var userName: Binding<UserName> {
        state.binding(
            get: \.userName,
            set: { state[keyPath: \AppState.userName] = $0 })
    }

    var body: some View {
        VStack(alignment: .center) {
            Text("ユーザー名を入力してください")
            TextField("ユーザー名", text: userName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Spacer()
        }
    }
}

struct UserNameView_Previews: PreviewProvider {
    static var previews: some View {
        UserNameView(state: AppState())
    }
}
