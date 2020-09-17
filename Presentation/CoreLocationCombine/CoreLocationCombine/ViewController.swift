//
//  ViewController.swift
//  CoreLocationCombine
//
//

import Combine
import UIKit
import MapKit

extension CLAuthorizationStatus {
    var name: String {
        switch self {
        case .notDetermined:
            return "Not Determined"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Denied"
        case .authorizedAlways:
            return "AuthorizedAlways"
        case .authorizedWhenInUse:
            return "AuthorizedWhenInUse"
        @unknown default:
            return "unknown"
        }
    }
}

final class ViewController: UIViewController {
    private let initialLocationLabelText = "Start Tracking"

    @IBOutlet weak var authorizationStatusLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!

    @IBAction func startTracking(_ sender: Any) {
        locationLabel.text = "Loading..."
        locationMonitor.start()
    }

    @IBAction func stopTracking(_ sender: Any) {
        locationMonitor.stop()
        locationLabel.text = initialLocationLabelText
    }

    private var cancellables = Set<AnyCancellable>()
    private let locationMonitor: LocationMonitor

    init?(coder: NSCoder, locationMonitor: LocationMonitor) {
        self.locationMonitor = locationMonitor
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        locationLabel.text = initialLocationLabelText
        setupBindings()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        authorizationStatusLabel.text = locationMonitor.authorizationStatus.name
    }

    private func setupBindings() {
        locationMonitor.delegatePublisher.sink { [weak self] event in
            switch event {
            case .didChangeAuthorization(let status):
                self?.authorizationStatusLabel.text = status.name
            case .didUpdateLocation(let coordinate):
                self?.locationLabel.text = "\(coordinate.description)"
            case .didFailWithError:
                self?.locationLabel.text = "Error! Plase try again!"
            }
        }
        .store(in: &cancellables)
    }
}
