//
//  GameEngine.swift
//  Game2048
//
//  Created by Vadim Popov on 05.05.2023.
//

import UIKit
import Combine


final class GameEngine {
    
    private var deskState: Desk? = nil
    
    public init() {
        if let deskStateValues = UserDefaults.standard.object(forKey: "deskStateValues") as? [[Int]],
           let deskStatePreviousValues = UserDefaults.standard.object(forKey: "deskStatePreviousValues") as? [[Int]]
        {
            deskState = {
                let oldDesk = Desk()
                oldDesk.values = deskStateValues
                oldDesk.previousValues = deskStatePreviousValues
                return oldDesk
            }()
        }
    }
    
    public func start() {
        finish()
        let newDesk = Desk()
        deskState = newDesk
        _ = addPoint()
    }
    
    public func finish() {
        deskState = nil
        UserDefaults.standard.removeObject(forKey: "deskStateValues")
        UserDefaults.standard.removeObject(forKey: "deskStatePreviousValues")
    }
    
    public func move(inDirection direction: Direction) -> Bool {
        guard let deskState else { return false }
        
        let xRange = Array( (direction == .bottom) ? stride(from: 3, through: 0, by: -1) : stride(from: 0, through: 3, by: 1) )
        let yRange = Array( (direction == .right)  ? stride(from: 3, through: 0, by: -1) : stride(from: 0, through: 3, by: 1) )
        
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
        
        let prev = deskState.values
        
        for i in 0..<4 {
            for j in 0..<4 {
                if direction == .bottom || direction == .top {
                    deskState.values[xRange[j]][yRange[i]] = extractedArrays[i][j]
                } else {
                    deskState.values[xRange[j]][yRange[i]] = extractedArrays[j][i]
                }
            }
        }
        
        if prev == deskState.values {
            return true
        }
        deskState.previousValues = prev
        let success = addPoint()
        saveState()
        return success
    }
    
    public func getDesk() -> DeskState? {
        return deskState
    }
    
    public func stepBack() {
        guard let deskState,
              let prev = deskState.previousValues
        else { return }
        deskState.values = prev
        saveState()
    }
    
    
    private func compressArray(_ arr: [Int]) -> [Int] {
        if arr[0] == arr[1] && arr[2] == arr[3] && arr[0] != 0 && arr[2] != 0 {
            return [arr[0] + 1, arr[2] + 1, 0, 0]
        }
        
        var res: [Int] = []
        var repeated = false
        for i in 0..<4 {
            if arr[i] > 0 {
                if !repeated && res.count > 0 && res[res.count - 1] == arr[i] {
                    res[res.count - 1] += 1
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
                    deskState.values[i][j] = Int.random(in: 0..<9) == 0 ? 2 : 1
                    return true
                } else {
                    randomX -= 1
                }
            }
        }
        return false
    }
    
    private func saveState() {
        guard let deskState, deskState.previousValues != nil else { return }
        UserDefaults.standard.setValue(deskState.values, forKey: "deskStateValues")
        UserDefaults.standard.setValue(deskState.previousValues, forKey: "deskStatePreviousValues")
        if UserDefaults.standard.integer(forKey: "maxScore") < deskState.getCurrentScore() {
            UserDefaults.standard.setValue(deskState.getCurrentScore(), forKey: "maxScore")
        }
    }
    
    
    final private class Desk: DeskState {
        
        var values: [[Int]] = {
            var a: [[Int]] = []
            (0..<4).forEach { _ in a.append(.init(repeating: 0, count: 4))}
            return a
        }()
        var previousValues: [[Int]]? = nil
        
        func getState() -> [[Int]] {
            return values
        }
        
        func getCurrentScore() -> Int {
            return values.reduce(0) { partialResult, arr in
                partialResult + arr.reduce(0, { partialResult1, val in
                    if val == 0 {
                        return partialResult1
                    }
                    return partialResult1 + scoreFrom(num: Int(pow(2.0, Double(val))))
                })
            }
        }
        
        private func scoreFrom(num: Int) -> Int {
            if num <= 2 {
                return 0
            }
            if num == 4 {
                return 4
            }
            return num + 2 * scoreFrom(num: num / 2)
        }
        
        func emptyPointsCount() -> Int {
            return values.reduce(0) { partialResult, arr in
                partialResult + arr.filter { $0 == 0 }.count
            }
        }
        
        func getNormValue(_ x: Int, _ y: Int) -> Int {
            return values[x][y]
        }
        
        func getExpValue(_ x: Int, _ y: Int) -> Int {
            if values[x][y] != 0 {
                return Int(pow(2.0, Double(values[x][y])))
            }
            return 0
        }
        
    }
    
    public enum Direction {
        case top
        case bottom
        case left
        case right
    }
    
}
