//
//  AddressCandidate.swift
//  ComplexUserRegistration
//
//

import Foundation
import Combine

struct AddressCandidate {
    var zipcode: String
    var prefecture: String
    var city: String
    var other: String
}

extension AddressCandidate: Hashable, Identifiable {
    var id: Self {
        self
    }

    init(apiResponse: ZipAPIResponse.Address) {
        self.zipcode = apiResponse.zipcode
        self.prefecture = apiResponse.address1
        self.city = apiResponse.address2 + apiResponse.address3
        self.other = ""
    }
}

struct ZipAPIResponse: Codable {
    var message: String?
    var status: Int
    var results: [Address]

    struct Address: Codable {
        var address1: String
        var address2: String
        var address3: String
        var zipcode: String
    }
}

// MARK: - Zip Client

struct ZipClient {
    var get:(Int) -> AnyPublisher<[AddressCandidate], Error>

    static let live = ZipClient { zipcode in
        let baseURL = URL(string: "https://zipcloud.ibsnet.co.jp/api/search?zipcode=\(zipcode)")!
        return URLSession.shared
            .dataTaskPublisher(for: baseURL)
            .map(\.data)
            .decode(type: ZipAPIResponse.self, decoder: JSONDecoder())
            .map { result in
                result.results.compactMap(AddressCandidate.init(apiResponse:))
            }
            .eraseToAnyPublisher()
    }

    static let mock = ZipClient { zipcode in
        Just(
            [
                AddressCandidate(zipcode: "\(zipcode)", prefecture: "Tokyo", city: "Tokyo", other: ""),
                AddressCandidate(zipcode: "\(zipcode)", prefecture: "Osaka", city: "Osaka", other: ""),
                AddressCandidate(zipcode: "\(zipcode)", prefecture: "Fukuoka", city: "Fukuoka", other: ""),
            ])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

// MARK: - AddressCandidateModel

final class AddressCandidateModel: ObservableObject {
    @Published private(set) var addressCandidates: [AddressCandidate] = []
    private var cancellables = Set<AnyCancellable>()
    private let client: ZipClient
    init(client: ZipClient) {
        self.client = client
    }

    func getAddressCandidates(zipcode: Int) {
        client.get(zipcode)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { finished in
                if case .failure(let error) = finished {
                    print(error.localizedDescription)
                }
            }, receiveValue: { [weak self] value in
                self?.addressCandidates = value
            }).store(in: &cancellables)
    }

    func clearAddressCandidates() {
        addressCandidates = []
    }
}


