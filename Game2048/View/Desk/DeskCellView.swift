//
//  DeskCellView.swift
//  Game2048
//
//  Created by Vadim Popov on 06.05.2023.
//

import UIKit


final class DeskCellView: UICollectionViewCell {
    
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var coloredView: UIView!
    
    public func setNumber(_ value: Int) {
        score.text = String(value)
        score.textColor = .systemBackground
    }
    
    public func setColor(_ color: UIColor) {
        coloredView.layer.cornerRadius = 8
        coloredView.backgroundColor = color
    }
    
}
