//
//  DeskState.swift
//  Game2048
//
//  Created by Vadim Popov on 05.05.2023.
//

import UIKit
import Combine


protocol DeskState {
    func getState() -> [[Int]]
    func getCurrentScore() -> Int
    func mayContinue() -> Bool
    
    var publisher: CurrentValueSubject<DeskState, Error> { get }
}
