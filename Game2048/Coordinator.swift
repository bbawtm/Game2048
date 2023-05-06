//
//  Coordinator.swift
//  Game2048
//
//  Created by Vadim Popov on 05.05.2023.
//

import UIKit


final class Coordinator {
    
    private var dependencies: [String: Any] = [:]
    
    public func getReference<T>(for type: T.Type) -> T {
        if let ref = dependencies[String(describing: type)] as? T {
            return ref
        }
        
        fatalError("getReference<\(type)> error")
    }
    
    public func setReference<T>(with obj: T) {
        dependencies[String(describing: T.self)] = obj
    }
    
    public init() {
        setReference(with: GameEngine())
        setReference(with: DeskVC())
    }
    
}

let coordinator = Coordinator()
