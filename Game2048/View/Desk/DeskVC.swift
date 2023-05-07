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
    
    private var collectionView: UICollectionView = {
        let view = UICollectionView(frame: CGRect(), collectionViewLayout: UICollectionViewFlowLayout())
        
        view.register(UINib(nibName: "DeskCollectionCell", bundle: .main), forCellWithReuseIdentifier: "DeskCell")
        view.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "collectionCell")
        
        view.layer.cornerRadius = 8
        view.layer.borderColor = UIColor.label.cgColor
        view.layer.borderWidth = 1
        view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let scoreField: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .label
        lbl.font = .systemFont(ofSize: 40)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let maxScore: UILabel = {
        let view = UILabel()
        view.textColor = .label
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var startNewGame: UIButton = {
        let btn = UIButton(configuration: .borderless(), primaryAction: UIAction(handler: { _ in
            let alert = UIAlertController(title: "Start again?", message: "The current account will be saved.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Go", style: .default, handler: { _ in
                let gameEngine = coordinator.getReference(for: GameEngine.self)
                gameEngine.start()
                self.linkDesk(withDesk: gameEngine.getDesk()!)
                self.collectionView.reloadData()
            }))
            self.present(alert, animated: true)
        }))
        let btnImage = UIImage(systemName: "arrow.triangle.2.circlepath.circle.fill")?.withTintColor(.label, renderingMode: .alwaysOriginal)
        btn.setImage(btnImage, for: .normal)
        btn.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 25), forImageIn: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private lazy var stepBack: UIButton = {
        let btn = UIButton(configuration: .borderless(), primaryAction: UIAction(handler: { _ in
            let gameEngine = coordinator.getReference(for: GameEngine.self)
            gameEngine.stepBack()
            self.collectionView.reloadData()
        }))
        let btnImage = UIImage(systemName: "arrowshape.turn.up.left.circle.fill")?.withTintColor(.label, renderingMode: .alwaysOriginal)
        btn.setImage(btnImage, for: .normal)
        btn.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 24), forImageIn: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        view.addSubview(scoreField)
        view.addSubview(maxScore)
        view.addSubview(startNewGame)
        view.addSubview(stepBack)
        
        NSLayoutConstraint.activate([
            collectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            collectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            collectionView.heightAnchor.constraint(equalTo: collectionView.widthAnchor, multiplier: 1.0),
            collectionView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            scoreField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            scoreField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            
            maxScore.topAnchor.constraint(equalTo: scoreField.bottomAnchor, constant: 12),
            maxScore.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            
            startNewGame.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            startNewGame.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 30),
            
            stepBack.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            stepBack.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 30),
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
        scoreField.text = "Score: \(currentDesk?.getCurrentScore() ?? 0)"
        maxScore.text = "Max score: \(UserDefaults.standard.integer(forKey: "maxScore"))"
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
        let x = indexPath.item / 4
        let y = indexPath.item % 4
        let number = currentDesk.getExpValue(x, y)
        if number != 0 {
            cell.setNumber(number)
            cell.setColor(.label.withAlphaComponent(min(0.1 + CGFloat(currentDesk.getNormValue(x, y)) / 11, 1.0)))
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
