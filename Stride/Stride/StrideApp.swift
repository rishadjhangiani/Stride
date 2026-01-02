//
//  StrideApp.swift
//  Stride
//
//  Created by Risha Jhangiani on 10/7/25.
//

import SwiftUI
import Supabase

@main
struct StrideApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    // Handle OAuth callback from Google sign-in
                    Task {
                        do {
                            // Process the OAuth callback URL
                            _ = try await DI.supabase.auth.session(from: url)
                            // Session is now set, SignInView will detect and dismiss
                        } catch {
                            print("OAuth callback error: \(error)")
                        }
                    }
                }
        }
    }
}
