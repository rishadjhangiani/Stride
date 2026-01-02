//
//  SupabaseClient.swift
//  Stride
//
//  Created by Risha Jhangiani on 10/7/25.
//

// bridge between ios app and supabase backend
    // every time app needs to
        // sign in a user, fetch or save data, call a function or storage engpoint
    // does through this client

import Supabase
import Foundation

// di stands for dependency injection
    // simple way to make this client globally accessible while keeping your code organized

// enum is a type that defines a fixed set of possible values in swift
    // a list of fixed choices your code can pick from
    // whereaas a struct + class are blueprints for objects that have properties and functions
enum DI {
    // initializes the sdk
    static let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://qicblqxevfcolgpgblbc.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFpY2JscXhldmZjb2xncGdibGJjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc4NzgwNjMsImV4cCI6MjA2MzQ1NDA2M30.6mfJrkAN09HkpqQOvD75UqLXoTCQNChqoQF-S1Yivwk"
    )
}
