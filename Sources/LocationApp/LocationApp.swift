//
//  LocationApp.swift
//  
//
//  Created by Sergei Runov on 07.09.2024.
//

import UIKit
import MapKit

public final class LocationApp: UIViewController {
    
    // MARK: - Public properties
    
    public let appName = "Location"
    public let appIconName = "mappin.and.ellipse"
    public var viewMode: String {
        didSet {
            mode = ViewMode(rawValue: viewMode)
        }
    }
    
    // MARK: - Subviews
    
    private let dismissButton = UIButton()
    private let map = MKMapView()
    private let titleLabel = UILabel()
    private let cityLabel = UILabel()
    private let adressLabel = UILabel()
    private let blurBackgroundView = UIVisualEffectView()
    
    // MARK: - Properties
    
    private let locationManager: LocationManagerProtocol
    private var mode: ViewMode? {
        didSet {
            setupLayout()
            setupInteractionMode()
        }
    }
    
    // MARK: - View Modes
    
    enum ViewMode: String {
        case compact, halfscreen, fullscreen
    }
    
    // MARK: - Lifecycle
    
    public init(viewMode: String = "compact") {
        self.viewMode = viewMode
        self.mode = ViewMode(rawValue: viewMode)
        self.locationManager = LocationManager()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupInteraction()
        setupAppearance()
        setupLayout()
    }
}

// MARK: - AppProtocol methods

public extension LocationApp {
    
    func setupInteractionMode() {
        guard let mode else { return }
        switch mode {
        case .compact:
            view.subviews.forEach {
                $0.isUserInteractionEnabled = false
            }
        case .halfscreen, .fullscreen:
            view.subviews.forEach {
                $0.isUserInteractionEnabled = true
            }
        }
    }
}

// MARK: - LocationManagerDelegate Methods

extension LocationApp: LocationManagerDelegate {
    func didUpdateLocation(_ location: CLLocation) {
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 50, longitudinalMeters: 200)
        map.setRegion(region, animated: true)
    }
    
    func didUpdatePlacemark(_ placemark: CLPlacemark?) {
        guard let placemark = placemark else { return }
        
        let city = placemark.locality ?? "Unknown"
        let countryCode = placemark.isoCountryCode == nil ? "" : ", \(placemark.isoCountryCode!)"
        let street = placemark.thoroughfare ?? ""
        DispatchQueue.main.async {
            self.cityLabel.text = city + countryCode
            self.adressLabel.text = street
        }
    }
}

// MARK: - Private setup methods

private extension LocationApp {
    
    func setupInteraction() {
        locationManager.delegate = self
        locationManager.requestAuthorization()
        locationManager.startUpdatingLocation()
        
        dismissButton.addTarget(self, action: #selector(didTapDismissButton), for: .touchUpInside)
    }
    
    func setupAppearance() {
        view.backgroundColor = .systemBackground
        view.layoutMargins = .init(top: 8, left: 16, bottom: 8, right: 16)
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        
        map.showsUserLocation = true
        
        dismissButton.backgroundColor = .systemGray5
        dismissButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        dismissButton.tintColor = .systemGray2
        dismissButton.layer.cornerRadius = 16
        
        cityLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        cityLabel.numberOfLines = 1
        cityLabel.textAlignment = .center
        cityLabel.text = "Unknown"

        adressLabel.font = .systemFont(ofSize: 13, weight: .regular)
        adressLabel.numberOfLines = 1
        adressLabel.textAlignment = .center
        
        titleLabel.font = .systemFont(ofSize: 15, weight: .light)
        titleLabel.text = "Your location:"
        titleLabel.textAlignment = .center
        
        blurBackgroundView.effect = UIBlurEffect(style: .regular)
        blurBackgroundView.layer.cornerRadius = 16
        blurBackgroundView.clipsToBounds = true
    }
    
    func setupLayout() {
        [map, cityLabel, adressLabel].forEach {
            view.addSubview($0)
        }
        
        [map, dismissButton, cityLabel, adressLabel, titleLabel, blurBackgroundView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate(mapConstraints)

        guard let mode else { return }
        switch mode {
        case .compact, .halfscreen:
            [dismissButton, titleLabel, blurBackgroundView].forEach {
                $0.removeFromSuperview()
            }
            
            NSLayoutConstraint.deactivate(fullscreenConstraints)
            NSLayoutConstraint.activate(compactConstraints)
        case .fullscreen:
            [dismissButton, titleLabel, blurBackgroundView].forEach {
                view.addSubview($0)
            }
            
            view.insertSubview(blurBackgroundView, at: 1)
            
            NSLayoutConstraint.deactivate(compactConstraints)
            NSLayoutConstraint.activate(fullscreenConstraints)
        }
    }
        
    @objc func didTapDismissButton() {
        dismiss(animated: true)
    }
}

// MARK: - Constraints

private extension LocationApp {
    
    var mapConstraints: [NSLayoutConstraint] {
        [
            map.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            map.topAnchor.constraint(equalTo: view.topAnchor),
            map.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            map.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
    }
    
    var fullscreenConstraints: [NSLayoutConstraint] {
        let margins = view.layoutMarginsGuide
        return [
            dismissButton.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            dismissButton.topAnchor.constraint(equalTo: margins.topAnchor),
            dismissButton.widthAnchor.constraint(equalToConstant: 32),
            dismissButton.heightAnchor.constraint(equalTo: dismissButton.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: 96),
            titleLabel.centerXAnchor.constraint(equalTo: margins.centerXAnchor),
            
            cityLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            cityLabel.leadingAnchor.constraint(equalTo: blurBackgroundView.leadingAnchor, constant: 16),
            cityLabel.trailingAnchor.constraint(equalTo: blurBackgroundView.trailingAnchor, constant: -16),

            adressLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 8),
            adressLabel.leadingAnchor.constraint(equalTo: cityLabel.leadingAnchor),
            adressLabel.trailingAnchor.constraint(equalTo: cityLabel.trailingAnchor),
            
            blurBackgroundView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            blurBackgroundView.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -32),
            blurBackgroundView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            blurBackgroundView.bottomAnchor.constraint(equalTo: adressLabel.bottomAnchor, constant: 32)
        ]
    }
    
    var compactConstraints: [NSLayoutConstraint] {
        let margins = view.layoutMarginsGuide
        return [
            cityLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            cityLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            cityLabel.topAnchor.constraint(equalTo: margins.topAnchor),

            adressLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            adressLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
        ]
    }
}
