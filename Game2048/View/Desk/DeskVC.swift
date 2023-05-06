//
//  DeskVC.swift
//  Game2048
//
//  Created by Vadim Popov on 05.05.2023.
//

import UIKit
import Combine


final class DeskVC: UIViewController {
    
    typealias DeskPublisher = CurrentValueSubject<DeskState, Error>
    
    private var deskPublisher: DeskPublisher?
    
    override func viewDidLoad() {
        coordinator.setReference(with: self)
    }
    
    public func linkDesk(withPublisher publisher: DeskPublisher) {
        deskPublisher = publisher
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(deskPublisher?.value.getCurrentScore())
    }
    
}
