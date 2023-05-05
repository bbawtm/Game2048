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
    
    public func switchToDesk(_ desk: DeskState) {
        let deskVC = coordinator.getReference(for: DeskVC.self)
        deskVC.reloadData(forDesk: desk)
        navigationContoller.pushViewController(deskVC, animated: true)
    }
    
    public func switchToMain() {
        navigationContoller.popViewController(animated: true)
    }
    
}
