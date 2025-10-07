//
//  LocationManager.swift
//  Stride
//
//  Created by Risha Jhangiani on 5/21/25.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLocationEnabled = false
    @Published var errorMessage: String?
    
    // Running state
    @Published var isTracking = false
    @Published var currentRun: Run?
    @Published var runHistory: [Run] = []
    @Published var completedRun: Run?
    @Published var isPaused = false
    private var pauseStartTime: Date?
    private var totalPausedTime: TimeInterval = 0
    @Published var timerTick: Date = Date()
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5 // Update every 5 meters
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startTracking() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            errorMessage = "Location permission required"
            return
        }
        
        isTracking = true
        isPaused = false
        totalPausedTime = 0
        pauseStartTime = nil
        currentRun = Run(startTime: Date())
        locationManager.startUpdatingLocation()
    }
    
    func stopTracking() {
        isTracking = false
        isPaused = false
        locationManager.stopUpdatingLocation()
        
        if let run = currentRun {
            var completedRun = run
            completedRun.endTime = Date()
            completedRun.totalPausedTime = totalPausedTime + (pauseStartTime != nil ? Date().timeIntervalSince(pauseStartTime!) : 0)
            runHistory.append(completedRun)
            self.completedRun = completedRun
            currentRun = nil
        }
        totalPausedTime = 0
        pauseStartTime = nil
    }
    
    func clearCompletedRun() {
        completedRun = nil
    }
    
    func pauseTracking() {
        guard isTracking, !isPaused else { return }
        isPaused = true
        pauseStartTime = Date()
        locationManager.stopUpdatingLocation()
        // Update currentRun's totalPausedTime for UI
        currentRun?.totalPausedTime = totalPausedTime
    }

    func resumeTracking() {
        guard isTracking, isPaused else { return }
        isPaused = false
        if let pauseStart = pauseStartTime {
            totalPausedTime += Date().timeIntervalSince(pauseStart)
        }
        pauseStartTime = nil
        locationManager.startUpdatingLocation()
        // Update currentRun's totalPausedTime for UI
        currentRun?.totalPausedTime = totalPausedTime
    }
    
    var hasActiveRun: Bool {
        return currentRun != nil && isTracking
    }
    
    var displayedDuration: TimeInterval {
        _ = timerTick // Force recompute when timerTick changes
        if isPaused, let pauseStart = pauseStartTime, let run = currentRun {
            return max(0, pauseStart.timeIntervalSince(run.startTime) - totalPausedTime)
        } else if let run = currentRun {
            return run.duration
        } else {
            return 0
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        self.location = location
        
        if isTracking, var run = currentRun {
            run.addLocation(location)
            currentRun = run
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "Location error: \(error.localizedDescription)"
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            isLocationEnabled = true
            errorMessage = nil
        case .denied, .restricted:
            isLocationEnabled = false
            errorMessage = "Location access denied"
        case .notDetermined:
            isLocationEnabled = false
        @unknown default:
            isLocationEnabled = false
        }
    }
}

// MARK: - Run Model
struct Run: Identifiable, Codable {
    var id = UUID()
    let startTime: Date
    var endTime: Date?
    var locations: [CLLocationCoordinate2D] = []
    var distance: Double = 0.0
    var totalPausedTime: TimeInterval = 0.0
    var duration: TimeInterval {
        guard let endTime = endTime else {
            return max(0, Date().timeIntervalSince(startTime) - totalPausedTime)
        }
        return max(0, endTime.timeIntervalSince(startTime) - totalPausedTime)
    }
    
    var averagePace: Double {
        guard distance > 0 else { return 0 }
        return duration / (distance / 1000) // minutes per kilometer
    }
    
    mutating func addLocation(_ location: CLLocation) {
        locations.append(location.coordinate)
        
        // Calculate distance
        if locations.count > 1 {
            let previousLocation = CLLocation(latitude: locations[locations.count - 2].latitude,
                                            longitude: locations[locations.count - 2].longitude)
            distance += location.distance(from: previousLocation)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, startTime, endTime, locations, distance
    }
}

// MARK: - CLLocationCoordinate2D Codable Extension
extension CLLocationCoordinate2D: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
    
    private enum CodingKeys: String, CodingKey {
        case latitude, longitude
    }
} 