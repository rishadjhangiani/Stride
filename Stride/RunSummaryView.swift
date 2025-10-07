//
//  RunSummaryView.swift
//  Stride
//
//  Created by Risha Jhangiani on 5/21/25.
//

import SwiftUI

struct RunSummaryView: View {
    let run: Run
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Run Completed!")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(run.startTime, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 40)
                
                // Stats
                VStack(spacing: 20) {
                    HStack(spacing: 40) {
                        StatItem(
                            title: "Distance",
                            value: String(format: "%.2f", run.distance / 1000),
                            unit: "km",
                            icon: "figure.run"
                        )
                        
                        StatItem(
                            title: "Duration",
                            value: formatDuration(run.duration),
                            unit: "",
                            icon: "clock"
                        )
                    }
                    
                    HStack(spacing: 40) {
                        StatItem(
                            title: "Pace",
                            value: String(format: "%.1f", run.averagePace),
                            unit: "min/km",
                            icon: "speedometer"
                        )
                        
                        StatItem(
                            title: "Speed",
                            value: formatSpeed(run.averagePace),
                            unit: "km/h",
                            icon: "gauge"
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 16) {
                    Button(action: {
                        // Run is already saved in LocationManager
                        locationManager.clearCompletedRun()
                        dismiss()
                    }) {
                        Text("Save Run")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.green)
                            .cornerRadius(28)
                    }
                    
                    Button(action: {
                        // Remove the run from history
                        if let index = locationManager.runHistory.firstIndex(where: { $0.id == run.id }) {
                            locationManager.runHistory.remove(at: index)
                        }
                        locationManager.clearCompletedRun()
                        dismiss()
                    }) {
                        Text("Discard Run")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(28)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .navigationBarHidden(true)
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
    
    private func formatSpeed(_ pace: Double) -> String {
        guard pace > 0 else { return "0.0" }
        let speed = 60.0 / pace // Convert pace to speed (km/h)
        return String(format: "%.1f", speed)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.orange)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}

struct RunSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        RunSummaryView(run: Run(startTime: Date()))
            .environmentObject(LocationManager())
    }
} 