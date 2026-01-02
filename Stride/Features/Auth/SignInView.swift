//
//  SignInView.swift
//  Stride
//
//  Created by Risha Jhangiani on 10/7/25.
//

import SwiftUI
import Supabase
import AuthenticationServices

class AuthSessionCoordinator: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            // Fallback: create a temporary window (shouldn't happen in normal flow)
            return UIWindow(frame: UIScreen.main.bounds)
        }
        return window
    }
}

struct SignInView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isSigningIn = false
    @State private var buttonBorderOpacity: Double = 0.08
    @State private var webAuthSession: ASWebAuthenticationSession?
    private let authCoordinator = AuthSessionCoordinator()
    
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
            
            // Content
            VStack(spacing: 0) {
                // Top section - "stride" text
                VStack {
                    Spacer()
                    
                    Text("stride")
                        .foregroundColor(.white.opacity(0.9))
                        .font(.system(size: 34, weight: .medium, design: .default))
                        .tracking(3.4)
                        .textCase(.lowercase)
                }
                .frame(maxWidth: .infinity)
                .frame(height: UIScreen.main.bounds.height * 0.3)
                
                Spacer()
                
                // Sign in section
                VStack(spacing: 24) {
                    // Title
                    Text("sign in")
                        .foregroundColor(.white.opacity(0.9))
                        .font(.system(size: 24, weight: .medium, design: .default))
                        .tracking(2.4)
                        .textCase(.lowercase)
                    
                    // Google sign in button
                    Button(action: {
                        signInWithGoogle()
                    }) {
                        ZStack {
                            Capsule()
                                .fill(.ultraThinMaterial.opacity(0.5))
                            Capsule()
                                .stroke(Color.white.opacity(buttonBorderOpacity * 0.7), lineWidth: 1)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "globe")
                                    .foregroundColor(.white)
                                    .font(.system(size: 18))
                                
                                Text("continue with google")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .medium, design: .default))
                                    .tracking(1.6)
                                    .textCase(.lowercase)
                            }
                        }
                        .frame(height: 56)
                        .padding(.horizontal, 80)
                    }
                    .buttonStyle(.plain)
                    .disabled(isSigningIn)
                    .opacity(isSigningIn ? 0.6 : 1.0)
                    .onLongPressGesture(minimumDuration: 0) { pressing in
                        if !isSigningIn {
                            withAnimation(.easeOut(duration: 0.2)) {
                                buttonBorderOpacity = pressing ? 0.2 : 0.08
                            }
                        }
                    } perform: {}
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 100)
            }
        }
        .onAppear {
            // Check if already signed in
            Task {
                do {
                    _ = try await DI.supabase.auth.session
                    // If we get here, we have a session
                    await MainActor.run {
                        dismiss()
                    }
                } catch {
                    // Not signed in - ignore error
                }
            }
        }
    }
    
    private func signInWithGoogle() {
        guard !isSigningIn else { return }
        
        isSigningIn = true
        
        Task {
            do {
                let redirectURL = URL(string: "Stride://auth-callback")!
                
                // Get the OAuth sign-in URL
                let oauthURL = try await DI.supabase.auth.getOAuthSignInURL(
                    provider: .google,
                    redirectTo: redirectURL
                )
                
                // Debug: Print the OAuth URL to verify it's correct
                print("OAuth URL: \(oauthURL.absoluteString)")
                
                await MainActor.run {
                    // Verify URL is valid before opening
                    guard oauthURL.scheme == "https" else {
                        print("ERROR: Invalid OAuth URL scheme: \(oauthURL)")
                        isSigningIn = false
                        return
                    }
                    
                    // Use ASWebAuthenticationSession for secure OAuth flow
                    let session = ASWebAuthenticationSession(
                        url: oauthURL,
                        callbackURLScheme: "Stride"
                    ) { callbackURL, error in
                        Task {
                            await MainActor.run {
                                isSigningIn = false
                            }
                            
                            if let error = error {
                                print("OAuth error: \(error)")
                                return
                            }
                            
                            guard let callbackURL = callbackURL else {
                                print("No callback URL received")
                                return
                            }
                            
                            do {
                                // Exchange the callback URL for a session
                                _ = try await DI.supabase.auth.session(from: callbackURL)
                                
                                // Sign-in successful
                                await MainActor.run {
                                    dismiss()
                                }
                            } catch {
                                print("Error exchanging session: \(error)")
                            }
                        }
                    }
                    
                    // Set presentation context for iOS
                    session.presentationContextProvider = authCoordinator
                    session.prefersEphemeralWebBrowserSession = false
                    
                    self.webAuthSession = session
                    session.start()
                }
            } catch {
                await MainActor.run {
                    isSigningIn = false
                    print("Error getting OAuth URL: \(error)")
                }
            }
        }
    }
}

#Preview {
    SignInView()
}


