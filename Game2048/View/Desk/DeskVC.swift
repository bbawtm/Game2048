//
//  DeskVC.swift
//  Game2048
//
//  Created by Vadim Popov on 05.05.2023.
//

import UIKit


final class DeskVC: UIViewController {
    
    override func viewDidLoad() {
        coordinator.setReference(with: self)
    }
    
    public func reloadData(forDesk desk: DeskState) {
        
    }
    
}
