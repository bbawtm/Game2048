//
//  GameEngine.swift
//  Game2048
//
//  Created by Vadim Popov on 05.05.2023.
//

import UIKit
import Combine

/*
 
 Board VC (View with desk_view, game_title, current_score, max_score, step_back, home_button)
 
 */


final class GameEngine {
    
    private var deskState: Desk? = nil
    
    public init() {
        if let currentScore = UserDefaults.standard.object(forKey: "deskStateCurrentScore") as? Int,
           let deskStateValues = UserDefaults.standard.object(forKey: "deskStateValues") as? [[Int]],
           let deskStatePreviousValues = UserDefaults.standard.object(forKey: "deskStatePreviousValues") as? [[Int]]
        {
            deskState = {
                let oldDesk = Desk()
                oldDesk.currentScore = currentScore
                oldDesk.values = deskStateValues
                oldDesk.previousValues = deskStatePreviousValues
                return oldDesk
            }()
        }
    }
    
    public func start() {
        let newDesk = Desk()
        deskState = newDesk
        _ = addPoint()
        newDesk.currentScore = newDesk.pointsExpSum()
    }
    
    public func finish() {
        deskState = nil
    }
    
    public func move(inDirection direction: Direction) -> Bool {
        guard let deskState else { return false }
        
        let xRange = Array( (direction == .bottom) ? stride(from: 3, through: 0, by: -1) : stride(from: 0, through: 3, by: 1) )
        let yRange = Array( (direction == .right) ? stride(from: 3, through: 0, by: -1) : stride(from: 0, through: 3, by: 1) )
        
        var extractedArrays: [[Int]] = []
        (0..<4).forEach { _ in extractedArrays.append([]) }
        
        for x in xRange {
            for y in yRange {
                if direction == .top || direction == .bottom {
                    extractedArrays[y].append(deskState.values[x][y])
                } else {
                    extractedArrays[x].append(deskState.values[x][y])
                }
            }
        }
        for i in 0..<4 {
            extractedArrays[i] = compressArray(extractedArrays[i])
        }
        
        deskState.previousValues = deskState.values
        
        for i in 0..<4 {
            for j in 0..<4 {
                if direction == .bottom || direction == .top {
                    deskState.values[xRange[j]][yRange[i]] = extractedArrays[i][j]
                } else {
                    deskState.values[xRange[j]][yRange[i]] = extractedArrays[j][i]
                }
            }
        }
        
        let success = !addPoint()
        deskState.currentScore = deskState.pointsExpSum()
        return success
    }
    
    public func getDesk() -> DeskState? {
        return deskState
    }
    
    
    private func compressArray(_ arr: [Int]) -> [Int] {
        if arr[0] == arr[1] && arr[2] == arr[3] {
            return [arr[0] * 2, arr[2] * 2, 0, 0]
        }
        
        var res: [Int] = []
        var repeated = false
        for i in 0..<4 {
            if arr[i] > 0 {
                if !repeated && res.count > 0 && res[res.count - 1] == arr[i] {
                    res[res.count - 1] *= 2
                    repeated = true
                } else {
                    res.append(arr[i])
                }
            }
        }
        return res + .init(repeating: 0, count: 4 - res.count)
    }
    
    private func addPoint() -> Bool {
        guard let deskState else { return  false }
        let emptyPoints = deskState.emptyPointsCount()
        if emptyPoints == 0 {
            return false
        }
        var randomX = Int.random(in: 0..<emptyPoints)
        for i in 0..<4 {
            for j in 0..<4 {
                if deskState.values[i][j] != 0 {
                    continue
                }
                if randomX == 0 {
                    deskState.values[i][j] = 1
                    print("added \(i) \(j)")
                    return true
                } else {
                    randomX -= 1
                }
            }
        }
        return false
    }
    
    
    
    final private class Desk: DeskState {
        
        private var thisCurrentValue: Int = 0
        var currentScore: Int {
            get {
                thisCurrentValue
            }
            set {
                thisCurrentValue = newValue
                publisher.send(self)
            }
        }
        var values: [[Int]] = .init(repeating: .init(repeating: 0, count: 4), count: 4)
        var previousValues: [[Int]] = .init(repeating: .init(repeating: 0, count: 4), count: 4)
        
        func getState() -> [[Int]] {
            return values
        }
        
        func getCurrentScore() -> Int {
            return currentScore
        }
        
        func emptyPointsCount() -> Int {
            return values.reduce(0) { partialResult, arr in
                partialResult + arr.filter { $0 == 0 }.count
            }
        }
        
        func pointsExpSum() -> Int {
            return values.reduce(0) { partialResult, arr in
                partialResult + arr.reduce(0, { partialResult1, val in
                    partialResult1 + Int(pow(2.0, Double(val)))
                })
            }
        }
        
        func mayContinue() -> Bool {
            return emptyPointsCount() != 0
        }
        
        private lazy var thisPublisher: CurrentValueSubject<DeskState, Error> = .init(self)
        var publisher: CurrentValueSubject<DeskState, Error> {
            get {
                thisPublisher
            }
        }
        
    }
    
    public enum Direction {
        case top
        case bottom
        case left
        case right
    }
    
}
