//
//  LocationMonitor.swift
//  CoreLocationCombine
//
//

import Foundation
import Combine
import MapKit

struct Coordinate {
    let latitude: Double
    let longitude: Double

    var description: String {
        """
        緯度: \(latitude)
        経度: \(longitude)
        """
    }
}

final class LocationMonitor: NSObject {
    private let manager: CLLocationManager
    init(manager: CLLocationManager) {
        self.manager = manager
        super.init()
        self.manager.delegate = self
    }

    private let delegateSubject = PassthroughSubject<DelegateEvent, Never>()
    var delegatePublisher: AnyPublisher<DelegateEvent, Never> {
        delegateSubject
            .handleEvents(
                receiveSubscription: { [self] _ in
                    self.startIfAuthorized()
                }, receiveCancel: { [manager] in
                    manager.stopUpdatingLocation()
                })
            .eraseToAnyPublisher()
    }

    var authorizationStatus: CLAuthorizationStatus {
        manager.authorizationStatus
    }

    enum DelegateEvent {
        case didChangeAuthorization(CLAuthorizationStatus)
        case didUpdateLocation(Coordinate)
        case didFailWithError(Error)
    }

    private func startIfAuthorized() {
        if case .authorizedWhenInUse = manager.authorizationStatus {
            manager.startUpdatingLocation()
        }
    }

    func start() {
        manager.startUpdatingLocation()
    }

    func stop() {
        manager.stopUpdatingLocation()
    }
}

extension LocationMonitor: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        delegateSubject.send(.didChangeAuthorization(manager.authorizationStatus))
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        let coordinate = Coordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        delegateSubject.send(.didUpdateLocation(coordinate))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegateSubject.send(.didFailWithError(error))
    }
}
