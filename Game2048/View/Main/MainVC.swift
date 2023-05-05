//
//  MainVC.swift
//  Game2048
//
//  Created by Vadim Popov on 05.05.2023.
//

import UIKit


final class MainVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coordinator.setReference(with: self)
    }
    
}
