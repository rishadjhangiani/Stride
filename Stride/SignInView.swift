//
//  SignInView.swift
//  Stride
//
//  Created by Risha Jhangiani on 4/17/25.
//

import SwiftUI

struct SignInView: View {
    @StateObject var authVM = AuthViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var isSigningIn = false
    var onSignIn: (() -> Void)? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Spacer()
                
                // Header
                Text("Welcome to Stride")
                    .font(.system(size: 32, weight: .bold))
                    .padding(.top, 40)
                
                // Google Sign-In Button
                
                Button(action: {
                    Task {
                        isSigningIn = true
                        do {
                            try await supabase.auth.signInWithOAuth(
                                provider: .google,
                                redirectTo: URL(string: "Stride://auth-callback")
                            )
                            onSignIn?()
                        } catch {
                            authVM.errorMessage = error.localizedDescription
                        }
                        isSigningIn = false
                    }
                }) {
                    HStack {
                        Image(systemName: "globe")
                            .font(.title2)
                        Text("Sign in with Google")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.orange)
                    .cornerRadius(28)
                }
                .padding(.horizontal)
                .disabled(isSigningIn)
                
                
                // Temporary guest access for testing
                Button(action: {
                    onSignIn?()
                }) {
                    HStack {
                        Image(systemName: "person.crop.circle.badge.questionmark")
                            .font(.title2)
                        Text("Continue as Guest")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.gray)
                    .cornerRadius(28)
                }
                .padding(.horizontal)
                
                if isSigningIn {
                    ProgressView("Signing in...")
                        .padding()
                }
                
                if let error = authVM.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationBarItems(leading: Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.black)
            })
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
