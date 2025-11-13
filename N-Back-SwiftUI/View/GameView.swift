//
//  GameView.swift
//  N-Back-SwiftUI
//
//  Created by Majd Makhoul on 2025-11-07.
//

import SwiftUI

struct GameView: View {
    let mode: N_Back_SwiftUIVM.Mode
    @EnvironmentObject var vm: N_Back_SwiftUIVM

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 8), count: vm.gridSize)
    }

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Event \(vm.eventIndex)/\(vm.totalEvents)")
                Spacer()
                Text("Correct: \(vm.correct)")
            }
            .font(.headline)

            // Stimulus
            if mode == .visual {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(1...(vm.gridSize * vm.gridSize), id: \.self) { i in
                        RoundedRectangle(cornerRadius: 12)
                            .frame(height: 80)
                            .foregroundStyle(vm.activeGridPos == i ? .blue : .gray.opacity(0.2))
                            .overlay(Text("\(i)").opacity(0.18))
                            .scaleEffect(vm.activeGridPos == i ? 1.05 : 1.0)
                            .animation(.easeInOut(duration: 0.18), value: vm.activeGridPos)
                    }
                }
                .padding(.horizontal)
            } else {
                Spacer()
                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 60))
                Text("Listen…").opacity(0.7)
                Spacer()
            }

            // User controll + feedback
            Button("Match!") {
                vm.userSaysMatch()
            }
            .buttonStyle(.borderedProminent)
            .background(vm.wrongGuess ? Color.red : Color.blue)
            .cornerRadius(8)
            .foregroundColor(.white)
            .scaleEffect(vm.wrongGuess ? 1.2 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: vm.wrongGuess)
            

            HStack {
                Button("Stop") { vm.stopGame() }
                Spacer()
            }
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { vm.startGame(mode: mode) }
        .onDisappear { vm.stopGame() }
    }
}
