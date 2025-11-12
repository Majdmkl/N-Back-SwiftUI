//
//  N_Back_SwiftUIVM.swift
//  N-Back-SwiftUI
//
//  Created by Majid Makhoul on 2023-11-06.
//

import Foundation
import AVFoundation
import SwiftUI

class N_Back_SwiftUIVM : ObservableObject  {
    
    enum Mode {case visual, audio}
    
    @AppStorage("n") var n : Int = 2
    @AppStorage("totalEvents") var totalEvents: Int = 20
    @AppStorage("interval") var interval: Double = 1.5
    // för 5x5 senare
    @AppStorage("gridSize") var gridSize: Int = 3
    @AppStorage("lettersCount") var lettersCount: Int = 12
    @Published var correctVisual = 0
    @Published var correctAudio = 0
    
    //Results
    @Published var highScore: Int = 0
    @Published var eventIndex: Int = 0
    @Published var correct: Int = 0
    @Published var activeGridPos: Int? = nil
    @Published var wrongGuess: Bool = false
    @Published var isRunning: Bool = false
    @Published var isDual = false
    var canMatchNow: Bool { eventIndex > n }

    
    private var timer: Timer?
    private var sequence: [Int] = []
    private let allLetters = Array("ABCDFGHKMPRSTVW")
    var letters: [Character] {Array(allLetters.prefix(lettersCount))}
    private(set) var mode: Mode = .visual
    private var sequenceVisual: [Int] = []
    private var sequenceAudio: [Int] = []

    let synthesizer = AVSpeechSynthesizer()
    private var model = N_BackSwiftUIModel()
    
    //Controllers
    func startGame(mode: Mode) {
        isDual = false
        self.mode = mode
        eventIndex = 0
        correct = 0
        wrongGuess = false
        isRunning = true

        let combinations = (mode == .visual) ? gridSize * gridSize : letters.count
        model.newRound(size: totalEvents, combinations: combinations, matchPercentage: 20, nback: n)
        sequence = model.current

        scheduleTimer()
    }
    
    func stopGame() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        
        let lastScore = isDual ? (correctVisual + correctAudio) : correct
        model.finishRound(correct: lastScore)
        highScore = max(highScore, model.highScore)
        
        activeGridPos = nil
        isDual = false
    }

    func userSaysMatch() {
        let idx = eventIndex - 1 // use last shown
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
          guard eventIndex < totalEvents else { stopGame(); return }

            if isDual {
                // Dual: shows box + letter
                let v = sequenceVisual[eventIndex]
                activeGridPos = v

                let a = sequenceAudio[eventIndex]
                let letter = String(letters[(a - 1) % letters.count])
                speech(aString: letter)
              } else {
                  // Single: Visual or Audio
                  let value = sequence[eventIndex]
                  if mode == .visual {
                      activeGridPos = value
                  } else {
                      let letter = String(letters[(value - 1) % letters.count])
                      speech(aString: letter)
                  }
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
    
    func startDual(){
        //show and play sound at the same time
        isDual = true
        mode = .visual
        eventIndex = 0
        correctVisual = 0
        correctAudio = 0
        wrongGuess = false
        isRunning = true
    
        // 9 combinations from 3x3
        model.newRound(size: totalEvents, combinations: gridSize * gridSize, matchPercentage: 20, nback: n)
        
        sequenceVisual = model.current
        
        // Audio = number of characters
        model.newRound(size: totalEvents, combinations: letters.count, matchPercentage: 20, nback: n)
        
        sequenceAudio = model.current
        
        scheduleTimer()
    }
    
    func userSaysMatchVisual(){
        let idx = eventIndex - 1
        guard idx - n >= 0 else {return}
        if sequenceVisual[idx] == sequenceVisual[idx - n]{
            correctVisual += 1
        }else{
            flashError()
        }
    }
    
    func userSaysMatchAudio(){
        let idx = eventIndex - 1
        guard idx - n >= 0 else {return}
        if sequenceAudio[idx] == sequenceAudio[idx - n]{
            correctAudio += 1
        }else{
            flashError()
        }
    }
}






