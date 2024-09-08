//
//  LocationManager.swift
//
//
//  Created by Sergei Runov on 08.09.2024.
//

import CoreLocation

protocol LocationManagerDelegate: AnyObject {
    func didUpdateLocation(_ location: CLLocation)
    func didUpdatePlacemark(_ placemark: CLPlacemark?)
}

final class LocationManager: NSObject, LocationManagerProtocol {
        
    // MARK: - Properties
    
    private let manager = CLLocationManager()
    weak var delegate: LocationManagerDelegate?
    private let delayBetweenRequests: TimeInterval = 60
    private var lastRequestTime: Date?
    private let queue = DispatchQueue(label: "com.example.locationManagerQueue", qos: .utility)
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
    }
    
    // MARK: - Methods
    
    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
    
    // MARK: - Private methods
    
    private func getPlacemark(for location: CLLocation) {
        let now = Date()
        
        if let lastRequestTime {
            let timeSinceLastRequest = now.timeIntervalSince(lastRequestTime)
            if timeSinceLastRequest < delayBetweenRequests {
                let delay = delayBetweenRequests - timeSinceLastRequest
                queue.asyncAfter(deadline: .now() + delay) { [weak self] in
                    self?.getPlacemark(for: location)
                }
                return
            }
        }
        
        self.lastRequestTime = now
        queue.async {
            CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, error in
                guard error == nil else {
                    print("Error while trying to get location info")
                    return
                }
                self?.delegate?.didUpdatePlacemark(placemarks?.first)
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate methods

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        delegate?.didUpdateLocation(location)
        getPlacemark(for: location)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        default:
            print("Can't access location")
        }
    }
}
