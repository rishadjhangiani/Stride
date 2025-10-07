//
//  HomeView.swift
//  Stride
//
//  Created by Risha Jhangiani on 4/16/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var isShowingSignIn = false
        
    var body: some View {
                GeometryReader { geometry in
                    ZStack {
                        // Background layer
                        GeometryReader { geo in
                            Image("run")
                                .resizable()
                                    .scaledToFill()
                                    .frame(maxHeight: .infinity)
                                    .clipped()
                        }

                        // Gradient Overlay (optional)
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.7),
                                Color.black.opacity(0.3)
                            ]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                        .ignoresSafeArea()

                        // Foreground content
                        VStack {
                            Spacer()
                            VStack(alignment: .leading, spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Discover Your")
                                        .font(.system(size: 40, weight: .bold))
                                    Text("Perfect Route")
                                        .font(.system(size: 40, weight: .bold))
                                }
                                .foregroundColor(.white)

                                Text("Run with purpose. Whether you want to explore local gems or hit a specific distance, we'll create personalized routes based on your interests - from coffee shops to scenic parks.")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.8))
                                    .lineSpacing(4)
                                    .padding(.top, 4)

                                Button(action: {
                                    isShowingSignIn = true
                                }) {
                                    HStack {
                                        Text("Get Started")
                                            .font(.system(size: 17, weight: .semibold))
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 24)
                                    .frame(height: 56)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.orange)
                                    .cornerRadius(28)
                                }
                                .fullScreenCover(isPresented: $isShowingSignIn) {
                                    SignInView()
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 48)
                        }
                        .frame(maxWidth: .infinity) // Safe, clean width
                    }
                    .ignoresSafeArea()
                }
                .onOpenURL { url in
                    Task {
                        _ = try? await supabase.auth.session(from: url)
                        await authVM.loadSession()
                    }
                }
            }
    }

    struct HomeView_Previews: PreviewProvider {
        static var previews: some View {
            HomeView()
        }
    }
