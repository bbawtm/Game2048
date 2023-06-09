//
//  GameEngineTests.swift
//  Game2048Tests
//
//  Created by Вадим Попов on 05.05.2023.
//

import XCTest

final class GameEngineTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    private func printState(_ deskState: DeskState) {
        let arr = deskState.getState()
        for el in arr {
            print(el)
        }
    }
    
    private func findFirstItem(_ deskState: DeskState) -> (Int, Int)? {
        let values = deskState.getState()
        for i in 0..<4 {
            for j in 0..<4 {
                if values[i][j] > 0 {
                    return (i, j)
                }
            }
        }
        return nil
    }
    
    private func singleDirectionSwipe(_ direction: GameEngine.Direction) throws {
        let engine = GameEngine()
        engine.start()
//        print()
//        print()
//        print(direction)
//        printState(engine.getDesk()!)
        
        guard let itemIndexTuple = findFirstItem(engine.getDesk()!) else {
            XCTAssertNotNil(nil)
            return
        }
//        print(itemIndexTuple)
        
        XCTAssertTrue(engine.move(inDirection: direction))
        let newState = engine.getDesk()?.getState()
//        printState(engine.getDesk()!)
        XCTAssertNotNil(newState)
        
        switch direction {
        case .bottom:
            XCTAssertTrue(newState![3][itemIndexTuple.1] == 1 || newState![3][itemIndexTuple.1] == 2)
        case .left:
            XCTAssertTrue(newState![itemIndexTuple.0][0] == 1 || newState![itemIndexTuple.0][0] == 2)
        case .right:
            XCTAssertTrue(newState![itemIndexTuple.0][3] == 1 || newState![itemIndexTuple.0][3] == 2)
        case .top:
            XCTAssertTrue(newState![0][itemIndexTuple.1] == 1 || newState![0][itemIndexTuple.1] == 2)
        }
        
        let score = engine.getDesk()!.getCurrentScore()
        XCTAssertTrue(score == 0 || score == 4 || score == 8)
    }

    func testSingleDirectionSwipe() throws {
        for _ in 0..<100 {
            try! singleDirectionSwipe(.bottom)
            try! singleDirectionSwipe(.left)
            try! singleDirectionSwipe(.right)
            try! singleDirectionSwipe(.top)
        }
    }

}
