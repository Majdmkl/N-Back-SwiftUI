//
//  N_Back_SwiftUIModel.swift
//  N-Back-SwiftUI
//
//  Created by Majid Makhoul on 2023-11-07.
//

import Foundation

struct N_BackSwiftUIModel {
    private(set) var highScore: Int = 0
    private(set) var current: [Int] = []

    mutating func newRound(size: Int, combinations: Int, matchPercentage: Int, nback: Int) {
        current.removeAll()
        let s = create(Int32(size), Int32(combinations), Int32(matchPercentage), Int32(nback))
        for i in 0..<size {
            current.append(Int(getIndexOf(s, Int32(i))))
        }
    }

    mutating func finishRound(correct: Int) {
        highScore = max(highScore, correct)
    }
}

