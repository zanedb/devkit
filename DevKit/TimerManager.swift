//
//  TimerManager.swift
//  DevKit
//
//  Created by Zane Davis-Barrs on 4/2/25.
//

import Foundation
import WatchKit

// MARK: - Timer Model
struct DevelopmentTimer: Identifiable, Equatable {
    let id: Int
    let name: String
    let duration: TimeInterval
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        if seconds == 0 {
            return "\(minutes) min"
        } else {
            return "\(minutes):\(String(format: "%02d", seconds))"
        }
    }
}

// MARK: - Timer Manager
class TimerManager: ObservableObject {
    @Published var timers: [DevelopmentTimer] = [
        DevelopmentTimer(id: 1, name: "Developer", duration: 7 * 60),
        DevelopmentTimer(id: 2, name: "Fixer", duration: 5 * 60),
        DevelopmentTimer(id: 3, name: "Hypo Clear", duration: 2 * 60),
        DevelopmentTimer(id: 4, name: "Photo Flo", duration: 30)
    ]
    
    @Published var currentTimerIndex: Int = 0
    @Published var queue: [Int] = [0, 1, 2, 3]
    @Published var timeRemaining: TimeInterval = 7 * 60
    @Published var isRunning: Bool = false
    @Published var progress: Float = 0.0
    
    private var timer: Timer?
    private var vibrationTimer: Timer?
    private var lastVibrateTime: TimeInterval = 0

    func startTimer() {
        if !isRunning {
            isRunning = true
            
            // Set up the main timer
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 0.1
                    self.progress = 1.0 - Float(self.timeRemaining / self.timers[self.currentTimerIndex].duration)
                    
                    // Vibrate on 30-second intervals (excluding the start)
                    let elapsedTime = self.timers[self.currentTimerIndex].duration - self.timeRemaining
                    if elapsedTime >= 30.0 && Int(elapsedTime) % 30 == 0 && elapsedTime - self.lastVibrateTime >= 29.0 {
                        self.lastVibrateTime = elapsedTime
                        WKInterfaceDevice.current().play(.notification)
                    }
                } else {
                    self.completeTimer()
                }
            }
            
            RunLoop.current.add(timer!, forMode: .common)
        }
    }
    
    func completeTimer() {
        stopTimer()
        
        // Notify completion
        WKInterfaceDevice.current().play(.success)
        
        // Remove first item from queue
        if !queue.isEmpty {
            queue.removeFirst()
        }
        
        // Prepare next timer if available
        if !queue.isEmpty {
            currentTimerIndex = queue[0]
            timeRemaining = timers[currentTimerIndex].duration
            progress = 0.0
        }
    }
    
    func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        vibrationTimer?.invalidate()
        vibrationTimer = nil
        lastVibrateTime = 0
    }
    
    func reset() {
        stopTimer()
        queue = [0, 1, 2, 3]
        currentTimerIndex = 0
        timeRemaining = timers[currentTimerIndex].duration
        progress = 0.0
    }
    
    func switchTo(timerId: Int) {
        stopTimer()
        
        // Find the index of the timer
        if let index = timers.firstIndex(where: { $0.id == timerId }) {
            currentTimerIndex = index
            
            // Reset queue to include this timer and all subsequent timers
            queue = Array(index..<timers.count)
            
            timeRemaining = timers[currentTimerIndex].duration
            progress = 0.0
        }
    }
}
