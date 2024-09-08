//
//  LocationManagerProtocol.swift
//  
//
//  Created by Sergei Runov on 08.09.2024.
//

protocol LocationManagerProtocol: AnyObject {
    var delegate: LocationManagerDelegate? { get set }

    func requestAuthorization()
    func startUpdatingLocation()
    func stopUpdatingLocation()
}
