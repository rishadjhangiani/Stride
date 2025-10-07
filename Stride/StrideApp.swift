//
//  StrideApp.swift
//  Stride
//
//  Created by Risha Jhangiani on 4/16/25.
//

import SwiftUI
import Supabase


let supabase = SupabaseClient(
    supabaseURL: URL(string: "https://prljnkkvthjjoejmcozj.supabase.co")!,
    supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBybGpua2t2dGhqam9lam1jb3pqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIzNTAwMzMsImV4cCI6MjA2NzkyNjAzM30.8iqNON6QDkOpTEGT_yobRCSpsKQRJDdd5GqhJuT0Paw"
)

@main
struct StrideApp: App {
    @StateObject var authVM = AuthViewModel()
    @StateObject var locationManager = LocationManager()

    var body: some Scene {
        WindowGroup {
            Group {
                switch authVM.currentScreen {
                case .loading:
                    ProgressView()
                        .onAppear { Task { await authVM.loadSession() } }
                case .signIn:
                    SignInView(onSignIn: { Task { await authVM.handleSignIn() } })
                        .environmentObject(authVM)
                case .preferences:
                    PreferencesView(onComplete: { Task { await authVM.handlePreferencesSet() } })
                        .environmentObject(authVM)
                case .home:
                    MainView()
                        .environmentObject(locationManager)
                        .environmentObject(authVM)
                }
            }
        }
    }
}
