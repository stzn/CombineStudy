//
//  AddressView.swift
//  ComplexUserRegistration
//
//

import Combine
import SwiftUI

struct AddressView: View {
    @ObservedObject var state: AppState
    let client: ZipClient
    @StateObject var viewModel = AddressCandidateModel()

    private var zipcode: Binding<String> {
        state.binding(
            get: \.address.zipcode,
            set: {
                state[keyPath: \AppState.zipcode] = $0
                let value = zipcode.wrappedValue
                if value.count == 7, let intValue = Int(value) {
                    viewModel.getAddressCandidates(zipcode: intValue, using: client)
                } else {
                    viewModel.clearAddressCandidates()
                }
            }
        )
    }

    private var prefecture: Binding<String> {
        state.binding(
            get: \.address.prefecture,
            set: { state[keyPath: \AppState.prefecture] = $0 }
        )
    }

    private var city: Binding<String> {
        state.binding(
            get: \.address.city,
            set: { state[keyPath: \AppState.city] = $0 }
        )
    }

    private var other: Binding<String> {
        state.binding(
            get: \.address.other,
            set: { state[keyPath: \AppState.other] = $0 }
        )
    }

    private func selectAddressCandidate(_ candidate: AddressCandidate){
        self.prefecture.wrappedValue = candidate.prefecture
        self.city.wrappedValue = candidate.city
        self.other.wrappedValue = candidate.other
        viewModel.clearAddressCandidates()
    }

    // MARK: - Views

    var body: some View {
        Group {
            zipcodeView
            prefectureView
            cityView
            otherView
            Spacer()
        }
    }

    private var zipcodeView: some View {
        VStack(alignment: .leading) {
            Text("郵便番号")
            VStack(alignment: .leading, spacing: 2) {
                TextField("1111111", text: zipcode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                Text("※完全一致した場合に候補が出てきます")
                    .font(.caption)
            }

            if !viewModel.addressCandidates.isEmpty {
                ForEach(viewModel.addressCandidates){ candidate in
                    Text("\(candidate.prefecture) \(candidate.city) \(candidate.other)")
                        .onTapGesture {
                            selectAddressCandidate(candidate)
                        }
                }
                .padding(8)
                .border(Color.black, width: 3)
                .cornerRadius(3)
            }
        }
        .padding(.bottom)
    }

    private var prefectureView: some View {
        VStack(alignment: .leading) {
            Text("都道府県")
            TextField("都道府県", text: prefecture)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.bottom)
    }

    private var cityView: some View {
        VStack(alignment: .leading) {
            Text("市区町村")
            TextField("市区町村", text: city)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.bottom)
    }

    private var otherView: some View {
        VStack(alignment: .leading) {
            Text("それ以降")
            TextField("それ以降", text: other)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.bottom)
    }
}

struct AddressView_Previews: PreviewProvider {
    static var previews: some View {
        AddressView(state: AppState(), client: .mock)
    }
}
