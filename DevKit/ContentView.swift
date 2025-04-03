//
//  ContentView.swift
//  DevKit Watch App
//
//  Created by Zane Davis-Barrs on 4/2/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var timerManager: TimerManager
    @State private var showTimerList = false
    
    var body: some View {
        ZStack {
            // Progress ring = main ring, notches stacked with the right amount of padding
            ZStack {
                Circle()
                    .trim(from: 0, to: CGFloat(timerManager.timeRemaining / timerManager.timers[timerManager.currentTimerIndex].duration))
                    .stroke(
                        Color.orange.opacity(0.8),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                
                ForEach(0..<Int(ceil(timerManager.timers[timerManager.currentTimerIndex].duration / 30)), id: \.self) { index in
                    TimerBand(
                        totalDuration: timerManager.timers[timerManager.currentTimerIndex].duration,
                        bandTime: Double(index) * 30,
                        bandWidth: 0.015
                    )
                }
            }
                .padding(.top, -32)
                .padding(.bottom, 20)
            
            VStack(spacing: 0) {
                Text(formatTimeRemaining())
                    .font(.system(size: 42, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                
                Text(timerManager.timers[timerManager.currentTimerIndex].name.uppercased())
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.orange)
            }
                .padding(.top, -32)
                .padding(.bottom, 20)
            
            VStack {
                Spacer()
                
                HStack {
                    Button(action: {
                        showTimerList.toggle()
                    }) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                        .background(Circle().fill(Color.gray.opacity(0.25)).frame(width: 48, height: 48))
                        .padding(.leading, 12)
                        .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    Button(action: {
                        if timerManager.isRunning {
                            timerManager.stopTimer()
                        } else {
                            timerManager.startTimer()
                        }
                    }) {
                        Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.black)
                    }
                        .background(Circle().fill(Color.orange).frame(width: 44, height: 44))
                        .padding(.trailing, 16)
                        .buttonStyle(PlainButtonStyle())
                }
            }
                .padding(.bottom, -8)
        }
        .sheet(isPresented: $showTimerList) {
            TimerListView()
                .environmentObject(timerManager)
        }
        .onAppear {
            if timerManager.timeRemaining <= 0 {
                timerManager.reset()
            }
        }
    }
    
    func formatTimeRemaining() -> String {
        let minutes = Int(timerManager.timeRemaining) / 60
        let seconds = Int(timerManager.timeRemaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct TimerBand: View {
    let totalDuration: TimeInterval
    let bandTime: TimeInterval
    let bandWidth: CGFloat
    
    var body: some View {
        let anglePercent = Double(bandTime) / totalDuration
        
        Circle()
            .trim(from: max(0, CGFloat(anglePercent - bandWidth/2)),
                  to: min(1, CGFloat(anglePercent + bandWidth/2)))
            .stroke(Color.black, lineWidth: 10)
            .rotationEffect(.degrees(-90))
    }
}

struct TimerListView: View {
    @EnvironmentObject var timerManager: TimerManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            ForEach(timerManager.timers) { timer in
                Button(action: {
                    timerManager.switchTo(timerId: timer.id)
                    dismiss()
                }) {
                    HStack {
                        Text(timer.name)
                            .foregroundColor(.primary)
                        Spacer()
                        Text(timer.formattedDuration)
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                }
            }
        }
        .listStyle(CarouselListStyle())
        .navigationTitle("F76+")
    }
}

#Preview {
    ContentView()
        .environmentObject(TimerManager())
}
