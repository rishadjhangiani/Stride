//
//  ActiveRunView.swift
//  Stride
//
//  Created by Risha Jhangiani on 5/21/25.
//

import SwiftUI
import MapKit

struct ActiveRunView: View {
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.dismiss) private var dismiss
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var now = Date()
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Map background
                Map(coordinateRegion: $region, showsUserLocation: true)
                    .ignoresSafeArea()
                    .onReceive(locationManager.$location) { location in
                        if let location = location {
                            region.center = location.coordinate
                        }
                    }
                
                // Gradient overlay for better text readability
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.3),
                        Color.clear,
                        Color.clear,
                        Color.black.opacity(0.4)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack {
                    // Top stats bar
                    HStack {
                        Button(action: {
                            locationManager.stopTracking()
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Text("PACE")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.8))
                            
                            if let run = locationManager.currentRun {
                                Text(String(format: "%.1f", run.averagePace))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("min/km")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.8))
                            } else {
                                Text("--")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 60)
                    
                    Spacer()
                    
                    // Bottom stats panel
                    VStack(spacing: 0) {
                        // Main stats
                        HStack(spacing: 40) {
                            StatCard(
                                title: "DISTANCE",
                                value: formatDistance(locationManager.currentRun?.distance ?? 0),
                                unit: "km",
                                color: .orange
                            )
                            
                            StatCard(
                                title: "TIME",
                                value: formatDuration(locationManager.displayedDuration),
                                unit: "",
                                color: .blue
                            )
                            
                            StatCard(
                                title: "SPEED",
                                value: formatSpeed(locationManager.currentRun?.averagePace ?? 0),
                                unit: "km/h",
                                color: .green
                            )
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // Control buttons
                        HStack(spacing: 20) {
                            Button(action: {
                                if locationManager.isPaused {
                                    locationManager.resumeTracking()
                                } else {
                                    locationManager.pauseTracking()
                                }
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: locationManager.isPaused ? "play.circle.fill" : "pause.circle.fill")
                                        .font(.system(size: 40))
                                    Text(locationManager.isPaused ? "RESUME" : "PAUSE")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 80)
                                .background(Color.blue.opacity(0.8))
                                .cornerRadius(16)
                            }
                            .disabled(!locationManager.isTracking)
                            
                            Button(action: {
                                locationManager.stopTracking()
                                dismiss()
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "stop.circle.fill")
                                        .font(.system(size: 40))
                                    Text("STOP")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 80)
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(16)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.8))
                            .edgesIgnoringSafeArea(.bottom)
                    )
                }
            }
        }
        .navigationBarHidden(true)
        .statusBarHidden(true)
        .onReceive(timer) { _ in
            if locationManager.isTracking && !locationManager.isPaused {
                locationManager.timerTick = Date()
            }
        }
    }
    
    private func formatDistance(_ distance: Double) -> String {
        return String(format: "%.2f", distance / 1000)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    private func formatSpeed(_ pace: Double) -> String {
        guard pace > 0 else { return "0.0" }
        let speed = 60.0 / pace // Convert pace to speed (km/h)
        return String(format: "%.1f", speed)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.8))
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            if !unit.isEmpty {
                Text(unit)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(color.opacity(0.2))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.5), lineWidth: 1)
        )
    }
}

struct ActiveRunView_Previews: PreviewProvider {
    static var previews: some View {
        ActiveRunView()
            .environmentObject(LocationManager())
    }
} 
