//
//  AuthViewModel.swift
//  Stride
//
//  Created by Risha Jhangiani on 5/23/25.
//

import Foundation
import Supabase

enum AppScreen {
    case loading
    case signIn
    case preferences
    case home
}

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var currentScreen: AppScreen = .loading
    @Published var hasSetPreferences: Bool = false
    
    func signOut() async {
        try? await supabase.auth.signOut()
        isAuthenticated = false
        currentScreen = .signIn
    }
    
    @MainActor
    func loadSession() async {
        if let _ = try? await supabase.auth.session {
            isAuthenticated = true
            await checkUserMetadataAndRoute()
        } else {
            currentScreen = .signIn
        }
    }

    @MainActor
    func checkUserMetadataAndRoute() async {
        do {
            let user = try await supabase.auth.user()
            let hasPrefs = user.userMetadata["hasSetPreferences"] as? Bool ?? false
            hasSetPreferences = hasPrefs
            currentScreen = hasPrefs ? .home : .preferences
        } catch {
            currentScreen = .signIn
        }
    }

    @MainActor
    func handleSignIn() async {
        await checkUserMetadataAndRoute()
    }

    @MainActor
    func handlePreferencesSet() async {
        do {
            try await supabase.auth.update(user: UserAttributes(data: ["hasSetPreferences": true]))
            hasSetPreferences = true
            currentScreen = .home
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
