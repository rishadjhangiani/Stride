//
//  MainView.swift
//  Stride
//
//  Created by Risha Jhangiani on 5/21/25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        TabView {
            HomeTabView()
                .environmentObject(locationManager)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }

            RunHistoryView()
                .environmentObject(locationManager)
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("History")
                }

            ProfileView()
                .environmentObject(locationManager)
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
    }
}


struct HomeTabView: View {
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        NavigationView {
            VStack {
                if locationManager.isLocationEnabled {
                    RunTrackingView()
                } else {
                    LocationPermissionView()
                }
            }
            .navigationTitle("Home")
            .fullScreenCover(item: $locationManager.completedRun) { run in
                RunSummaryView(run: run)
                    .environmentObject(locationManager)
            }
        }
    }
}

struct LocationPermissionView: View {
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.circle")
                .font(.system(size: 80))
                .foregroundColor(.orange)
            
            Text("Location Access Required")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Stride needs access to your location to track your runs and create personalized routes.")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            Button(action: {
                locationManager.requestLocationPermission()
            }) {
                Text("Enable Location Access")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.orange)
                    .cornerRadius(28)
            }
            .padding(.horizontal)
            
            if let error = locationManager.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding()
    }
}

struct RunTrackingView: View {
    @EnvironmentObject var locationManager: LocationManager
    @State private var showingActiveRun = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Current run stats
            if let run = locationManager.currentRun {
                VStack(spacing: 20) {
                    Text("Current Run")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 40) {
                        VStack {
                            Text(String(format: "%.2f", run.distance / 1000))
                                .font(.title)
                                .fontWeight(.bold)
                            Text("km")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        VStack {
                            Text(formatDuration(run.duration))
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Time")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        VStack {
                            Text(String(format: "%.1f", run.averagePace))
                                .font(.title)
                                .fontWeight(.bold)
                            Text("min/km")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
            
            // Start/Stop button
            Button(action: {
                if locationManager.isTracking {
                    locationManager.stopTracking()
                } else {
                    locationManager.startTracking()
                    showingActiveRun = true
                }
            }) {
                HStack {
                    Image(systemName: locationManager.isTracking ? "stop.fill" : "play.fill")
                    Text(locationManager.isTracking ? "Stop Run" : "Start Run")
                }
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(locationManager.isTracking ? Color.red : Color.green)
                .cornerRadius(30)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .fullScreenCover(isPresented: $showingActiveRun) {
            ActiveRunView()
                .environmentObject(locationManager)
        }
        .onChange(of: locationManager.isTracking) { oldValue, newValue in
            if !newValue {
                showingActiveRun = false
            }
        }
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
}

struct RunHistoryView: View {
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        NavigationView {
            VStack {
                if locationManager.runHistory.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Runs Yet")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Complete your first run to see it here!")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    List(locationManager.runHistory) { run in
                        RunHistoryRow(run: run)
                    }
                }
            }
            .navigationTitle("Run History")
        }
    }
}

struct RunHistoryRow: View {
    let run: Run
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(run.startTime, style: .date)
                    .font(.headline)
                Spacer()
                Text(formatDuration(run.duration))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            HStack {
                Text(String(format: "%.2f km", run.distance / 1000))
                    .font(.subheadline)
                    .foregroundColor(.orange)
                
                Spacer()
                
                Text(String(format: "%.1f min/km", run.averagePace))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        
        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        } else {
            return String(format: "%dm", minutes)
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Profile stats
                VStack(spacing: 15) {
                    Text("Running Stats")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 40) {
                        VStack {
                            Text("\(locationManager.runHistory.count)")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Runs")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        VStack {
                            Text(String(format: "%.1f", totalDistance))
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Total km")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Settings
                VStack(spacing: 0) {
                    Button(action: {
                        // Future: Open settings
                    }) {
                        HStack {
                            Image(systemName: "gear")
                            Text("Settings")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color.white)
                    }
                    .foregroundColor(.black)
                    
                    Divider()
                    
                    Button(action: {
                        Task {
                            await authVM.signOut()
                        }
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                            Spacer()
                        }
                        .padding()
                        .background(Color.white)
                    }
                    .foregroundColor(.red)
                }
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
        }
    }
    
    private var totalDistance: Double {
        locationManager.runHistory.reduce(0) { $0 + $1.distance } / 1000
    }
}
