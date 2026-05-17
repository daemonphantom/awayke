//
//  AwaykeApp.swift
//  Awayke
//

import SwiftUI

@main
struct AwaykeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
