//
//  DeskVC.swift
//  Game2048
//
//  Created by Vadim Popov on 05.05.2023.
//

import UIKit
import Combine


final class DeskVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private var currentDesk: DeskState?
    private var subscription: AnyCancellable?
    private var collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: UICollectionViewFlowLayout())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "DeskCollectionCell", bundle: .main), forCellWithReuseIdentifier: "DeskCell")
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "collectionCell")
        
        collectionView.layer.cornerRadius = 8
        collectionView.layer.borderColor = UIColor.label.cgColor
        collectionView.layer.borderWidth = 1
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        NSLayoutConstraint.activate([
            collectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            collectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            collectionView.heightAnchor.constraint(equalTo: collectionView.widthAnchor, multiplier: 1.0),
            collectionView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])
        
        addSwipes()
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(gestureHandler(gesture:)))
        rightSwipe.direction = .right
        collectionView.addGestureRecognizer(rightSwipe)
    }
    
    public func linkDesk(withDesk desk: DeskState) {
        currentDesk = desk
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        subscription?.cancel()
    }
    
    // MARK: - Collection View Settings
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DeskCell", for: indexPath) as? DeskCellView else {
            fatalError("DeskCell doesn't comform to expected type")
        }
        guard let currentDesk else {
            fatalError("Desk Publisher doesn't provided")
        }
        let number = currentDesk.getExpValue(x: indexPath.item / 4, y: indexPath.item % 4)
        if number != 0 {
            cell.setNumber(number)
            cell.setColor(.darkGray)
            return cell
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: (collectionView.frame.width / 4) - 16, height: (collectionView.frame.height / 4) - 16)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    // MARK: - Add Gestures
    
    private func addSwipes() {
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(gestureHandler(gesture:)))
        rightSwipe.direction = .right
        collectionView.addGestureRecognizer(rightSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(gestureHandler(gesture:)))
        leftSwipe.direction = .left
        collectionView.addGestureRecognizer(leftSwipe)
        
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(gestureHandler(gesture:)))
        upSwipe.direction = .up
        collectionView.addGestureRecognizer(upSwipe)
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(gestureHandler(gesture:)))
        downSwipe.direction = .down
        collectionView.addGestureRecognizer(downSwipe)
    }
    
    @objc private func gestureHandler(gesture: UIGestureRecognizer) {
        guard let swipeGesture = gesture as? UISwipeGestureRecognizer else {
            return
        }
        
        let gameEngine = coordinator.getReference(for: GameEngine.self)
        var moveDirection: GameEngine.Direction = .right
        
        switch swipeGesture.direction {
        case .down:
            moveDirection = .bottom
        case .left:
            moveDirection = .left
        case .up:
            moveDirection = .top
        default:
            break
        }
        
        guard gameEngine.move(inDirection: moveDirection) else {
            print("Error occured")
            return
        }
        collectionView.reloadData()
    }
    
}
