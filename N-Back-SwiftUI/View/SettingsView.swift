//
//  SettingsView.swift
//  N-Back-SwiftUI
//
//  Created by Majd Makhoul on 2025-11-07.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var vm: N_Back_SwiftUIVM
    var body: some View {
        Form {
            Section("Pace & lenght") {
                Stepper("Events: \(vm.totalEvents)", value: $vm.totalEvents, in: 10...60, step: 5)
                Stepper("n: \(vm.n)", value: $vm.n, in: 1...5)
                Slider(value: $vm.interval, in: 0.7...2.5, step: 0.1) {
                    Text("Interval")
                } minimumValueLabel: { Text("0.7s") }
                  maximumValueLabel: { Text("2.5s") }
                Text("Interval: \(String(format: "%.1fs", vm.interval))")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section("Stimuli") {
                Stepper("Grid: \(vm.gridSize)×\(vm.gridSize)", value: $vm.gridSize, in: 3...5)
                Stepper("Letters: \(vm.lettersCount)", value: $vm.lettersCount, in: 6...20)
            }
        }
        .navigationTitle("Settings")
    }
}
