//
//  DevKitApp.swift
//  DevKit Watch App
//
//  Created by Zane Davis-Barrs on 4/2/25.
//

import SwiftUI
import WatchKit
import UserNotifications

@main
struct DevKitApp: App {
    @StateObject private var timerManager = TimerManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(timerManager)
        }
    }
    
    init() {
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
}
