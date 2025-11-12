//
//  DualGameView.swift
//  N-Back-SwiftUI
//
//  Created by Majd Makhoul on 2025-11-07.
//
import SwiftUI

struct DualGameView: View {
    @EnvironmentObject var vm: N_Back_SwiftUIVM
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 8), count: vm.gridSize)
    }

    var body: some View {
        VStack(spacing: 16){
            //Status
            HStack{
                Text("Event \(vm.eventIndex)/\(vm.totalEvents)")
                Spacer()
                Text("n=\(vm.n)")
            }.font(.headline)
            
            //Visual grid
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(1...(vm.gridSize * vm.gridSize), id: \.self) { i in
                    RoundedRectangle(cornerRadius: 12)
                        .frame(height: 64)
                        .foregroundStyle(vm.activeGridPos == i ? .blue : .gray.opacity(0.2))
                        .overlay(Text("\(i)").opacity(0.18))
                        .scaleEffect(vm.activeGridPos == i ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 0.18), value: vm.activeGridPos)
                }
            }
            .padding(.horizontal)
            
            // Audio ikon
                 VStack(spacing: 6) {
                     Image(systemName: "speaker.wave.3.fill").font(.system(size: 36))
                     Text("Listen…").opacity(0.6)
                 }.padding(.top, 4)

                 // Poäng
                 HStack {
                     Text("Picture: \(vm.correctVisual)")
                     Spacer()
                     Text("Sound: \(vm.correctAudio)")
                 }
                 .font(.subheadline)

                 // Knappar
                 HStack(spacing: 16) {
                     Button("Box match!") { vm.userSaysMatchVisual() }
                         .buttonStyle(.borderedProminent)
                     Button("Voice match!") { vm.userSaysMatchAudio() }
                         .buttonStyle(.borderedProminent)
                 }
                 .scaleEffect(vm.wrongGuess ? 0.95 : 1.0)
                 .animation(.spring(response: 0.25, dampingFraction: 0.6), value: vm.wrongGuess)

                 Button("Stop") { vm.stopGame() }.padding(.top, 8)

                 Spacer(minLength: 0)
             }
             .padding()
             .onAppear { vm.startDual() }
             .onDisappear { vm.stopGame() }
    }
}
