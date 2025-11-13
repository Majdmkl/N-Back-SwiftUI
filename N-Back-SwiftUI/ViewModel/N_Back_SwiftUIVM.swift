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
    @AppStorage("gridSize") var gridSize: Int = 3 // For 5x5 later
    @AppStorage("lettersCount") var lettersCount: Int = 12
    
    @Published var correctVisual = 0
    @Published var correctAudio = 0
    @Published var highScore: Int = 0 // Results
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
    
    // Updates timer highscore and empties boxes
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

    //Single-mode
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
                // Dual: shows box, indipendent of audio
                let v = sequenceVisual[eventIndex]
                activeGridPos = v
                
                // Play sound
                let a = sequenceAudio[eventIndex]
                let letter = String(letters[(a - 1) % letters.count])
                speech(aString: letter)
              } else {
                  // Single: Visual OR Audio
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
        mode = .visual // Show boxes + sounds in dual
        eventIndex = 0
        correctVisual = 0
        correctAudio = 0
        wrongGuess = false
        isRunning = true
    
        // Visual sequence (boxes)
        let visualCombinations = gridSize * gridSize
        model.newRound(size: totalEvents,
                       combinations: visualCombinations,
                       matchPercentage: 20,
                       nback: n)
        sequenceVisual = model.current   // Save visual sequence

        // Audio, depenetend on visual
           sequenceAudio = generateSequence(size: totalEvents, combinations: letters.count, matchPercentage: 20, nback: n)
        
        //Make the sound matches less depentent of visual
        if totalEvents > n {
            for i in n..<totalEvents {
                let visualMatch = sequenceVisual[i] == sequenceVisual[i - n]
                let audioMatch  = sequenceAudio[i] == sequenceAudio[i - n]

                // If both match on same event:
                if visualMatch && audioMatch {
                    // About half of the time we change the matching rate
                    if Bool.random() {
                        var newVal = sequenceAudio[i]
                        // choose a new letter other than N-Back match
                        while newVal == sequenceAudio[i - n] {
                            newVal = Int.random(in: 1...letters.count)
                        }
                        sequenceAudio[i] = newVal
                    }
                }
            }
        }
        scheduleTimer()
    }
    
    
    // Dual-mode
    func userSaysMatchVisual(){
        let idx = eventIndex - 1
        guard idx - n >= 0 else {flashError(); return}
        if sequenceVisual[idx] == sequenceVisual[idx - n]{
            correctVisual += 1
        }else{
            flashError()
        }
    }
    
    // Dual-mode
    func userSaysMatchAudio(){
        let idx = eventIndex - 1
        guard idx - n >= 0 else {flashError(); return}
        if sequenceAudio[idx] == sequenceAudio[idx - n]{
            correctAudio += 1
        }else{
            flashError()
        }
    }
    
    //New generator for Audio sequence
    private func generateSequence(size: Int, combinations: Int, matchPercentage: Int, nback: Int) -> [Int] {
        var result: [Int] = []
        let matchProb = Double(matchPercentage) / 100.0

        for i in 0..<size {
            if i < nback {
                // First n value can not be an N-Back match, randomly generate
                result.append(Int.random(in: 1...combinations))
            } else {
                if Double.random(in: 0...1) < matchProb {
                    // Force an N-Back match
                    result.append(result[i - nback])
                } else {
                    // Use another value than N-Back value
                    var candidate: Int
                    repeat {
                        candidate = Int.random(in: 1...combinations)
                    } while candidate == result[i - nback]
                    result.append(candidate)
                }
            }
        }
        return result
    }

}






