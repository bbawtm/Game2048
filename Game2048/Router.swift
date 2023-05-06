//
//  Router.swift
//  Game2048
//
//  Created by Vadim Popov on 05.05.2023.
//

import UIKit


final class Router {
    
    private let navigationContoller: UINavigationController
    
    public init(navigationContoller: UINavigationController) {
        self.navigationContoller = navigationContoller
    }
    
    public func switchToDesk(shouldMakeNewDesk: Bool) {
        let gameEngine = coordinator.getReference(for: GameEngine.self)
        if shouldMakeNewDesk || gameEngine.getDesk() == nil {
            gameEngine.start()
        }
        let deskVC = coordinator.getReference(for: DeskVC.self)
        guard let desk = gameEngine.getDesk() else {
            fatalError("GameEngine didn't provide DeskState")
        }
        deskVC.linkDesk(withPublisher: desk.publisher)
        navigationContoller.pushViewController(deskVC, animated: true)
    }
    
    public func switchToMain() {
        navigationContoller.popViewController(animated: true)
    }
    
}
