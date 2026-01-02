//
//  ContentView.swift
//  Stride
//
//  Created by Risha Jhangiani on 10/7/25.
//

import SwiftUI

struct ContentView: View {
    @State private var topSectionOpacity: Double = 0
    @State private var topSectionOffset: CGFloat = -20
    @State private var bottomSectionOpacity: Double = 0
    @State private var bottomSectionOffset: CGFloat = 20
    @State private var buttonBorderOpacity: Double = 0.08
    @State private var showSignIn = false
    
    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
            
            // Background image with increased visibility
            Image("Runners Image Nov 5 2025")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(0.6)
                .ignoresSafeArea()
            
            // Reduced black overlay for more background visibility
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            // Content overlay
            VStack(spacing: 0) {
                // Top section - "stride" centered vertically in upper portion
        VStack {
                    Spacer()
                    
                    Text("stride")
                        .foregroundColor(.white.opacity(0.9))
                        .font(.system(size: 34, weight: .medium, design: .default))
                        .tracking(3.4) // 0.2em ≈ 3-4 points
                        .textCase(.lowercase)
                        .opacity(topSectionOpacity)
                        .offset(y: topSectionOffset)
                }
                .frame(maxWidth: .infinity)
                .frame(height: UIScreen.main.bounds.height * 0.5)
                
                Spacer()
                
                // Bottom section
                VStack(spacing: 24) {
                    // Tagline
                    Text("run with purpose")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .tracking(1.6) // 0.1em ≈ 1-2 points
                        .textCase(.lowercase)
                        .multilineTextAlignment(.center)
                        .opacity(bottomSectionOpacity)
                        .offset(y: bottomSectionOffset)
                    
                    // Button
                    Button(action: {
                        showSignIn = true
                    }) {
                        ZStack {
                            Capsule()
                                .fill(.ultraThinMaterial.opacity(0.5))
                            Capsule()
                                .stroke(Color.white.opacity(buttonBorderOpacity * 0.7), lineWidth: 1)
                            
                            Text("let's run")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .medium, design: .default))
                                .tracking(1.6) // 0.1em
                                .textCase(.lowercase)
                        }
                        .frame(height: 56)
                        .padding(.horizontal, 80)
                    }
                    .buttonStyle(.plain)
                    .opacity(bottomSectionOpacity)
                    .offset(y: bottomSectionOffset)
                    .onLongPressGesture(minimumDuration: 0) { pressing in
                        withAnimation(.easeOut(duration: 0.2)) {
                            buttonBorderOpacity = pressing ? 0.2 : 0.08
                        }
                    } perform: {}
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 64)
            }
        }
        .fullScreenCover(isPresented: $showSignIn) {
            SignInView()
        }
        .onAppear {
            // Animate top section
            withAnimation(.easeOut(duration: 0.8)) {
                topSectionOpacity = 1
                topSectionOffset = 0
            }
            
            // Animate bottom section with delay
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                bottomSectionOpacity = 1
                bottomSectionOffset = 0
            }
        }
    }
}

#Preview {
    ContentView()
}
