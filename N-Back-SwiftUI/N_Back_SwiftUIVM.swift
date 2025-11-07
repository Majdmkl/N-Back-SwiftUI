//
//  N_Back_SwiftUIVM.swift
//  N-Back-SwiftUI
//
//  Created by Majid Makhoul on 2023-11-06.
//

import Foundation
import AVFoundation

class N_Back_SwiftUIVM : ObservableObject  {
    
    enum Mode {case visual, audio}
    
    @Published var n: Int = 2
    @Published var totalEvents: Int = 20
    @Published var interval: TimeInterval = 1.5
    
    //Results
    @Published var highScore: Int = 0
    @Published var eventIndex: Int = 0
    @Published var correct: Int = 0
    @Published var activeGridPos: Int? = nil
    @Published var wrongGuess: Bool = false
    @Published var isRunning: Bool = false
    
    private var timer: Timer?
    private var sequence: [Int] = []
    private let letters = Array("ABCDFGHKMPRS")
    private(set) var mode: Mode = .visual

    let synthesizer = AVSpeechSynthesizer()
    private var model = N_BackSwiftUIModel()
    
    //Controllers
    func startGame(mode: Mode) {
            self.mode = mode
            eventIndex = 0
            correct = 0
            wrongGuess = false
            isRunning = true

            let combinations = (mode == .visual) ? 9 : letters.count
            model.newRound(size: totalEvents, combinations: combinations, matchPercentage: 20, nback: n)
            sequence = model.current

            scheduleTimer()
        }
    
    func stopGame() {
            timer?.invalidate()
            timer = nil
            isRunning = false
            model.finishRound(correct: correct)
            highScore = max(highScore, model.highScore)
            activeGridPos = nil
        }

    func userSaysMatch() {
            let idx = eventIndex - 1 // använd senaste visade
            guard idx - n >= 0 else { flashError(); return }
            if sequence[idx] == sequence[idx - n] {
                correct += 1
            } else {
                flashError()
            }
        }
    
    //Timer
      private func scheduleTimer() {
          timer?.invalidate()
          timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
              self?.tick()
          }
      }

      private func tick() {
          guard eventIndex < totalEvents else {
              stopGame()
              return
          }
          let value = sequence[eventIndex]

          if mode == .visual {
              activeGridPos = value // 1..9
          } else {
              let letter = String(letters[(value - 1) % letters.count])
              speech(aString: letter)
          }

          eventIndex += 1
      }

      private func flashError() {
          wrongGuess = true
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
              self?.wrongGuess = false
          }
      }

      //IO
      func speech(aString: String){
          let u = AVSpeechUtterance(string: aString)
          synthesizer.stopSpeaking(at: .immediate )
          synthesizer.speak(u)
      }
}






