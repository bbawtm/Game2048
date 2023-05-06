//
//  MainVC.swift
//  Game2048
//
//  Created by Vadim Popov on 05.05.2023.
//

import UIKit


final class MainVC: UIViewController {
    
    private let gameTitle: UILabel = {
        let view = UILabel()
        view.text = "2048"
        view.font = .boldSystemFont(ofSize: 40)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let maxScore: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let playButton: UIButton = {
        let button = UIButton(configuration: .borderless(), primaryAction: UIAction(handler: { action in
            coordinator.getReference(for: Router.self).switchToDesk(shouldMakeNewDesk: true)
        }))
        guard let buttonImage = UIImage(systemName: "play.square.fill") else {
            fatalError("Button image not found")
        }
        button.setImage(buttonImage.withTintColor(.label, renderingMode: .alwaysOriginal), for: .normal)
        button.setImage(buttonImage.withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal), for: .highlighted)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 48), forImageIn: .normal)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 48), forImageIn: .highlighted)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let continueButton: UIButton = {
        let button = UIButton(configuration: .gray(), primaryAction: UIAction(handler: { action in
            coordinator.getReference(for: Router.self).switchToDesk(shouldMakeNewDesk: false)
        }))
        button.setTitle("Or continue previous game", for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coordinator.setReference(with: self)
        
        view.addSubview(gameTitle)
        view.addSubview(maxScore)
        view.addSubview(playButton)
        view.backgroundColor = .systemBackground
        
        NSLayoutConstraint.activate([
            gameTitle.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            gameTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            maxScore.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            maxScore.topAnchor.constraint(equalTo: gameTitle.bottomAnchor, constant: 10),
            playButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            playButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -150),
            playButton.heightAnchor.constraint(equalToConstant: 60),
            playButton.widthAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        maxScore.text = "Maximum score: \(UserDefaults.standard.integer(forKey: "maxScore"))"
        
        if coordinator.getReference(for: GameEngine.self).getDesk() != nil {
            view.addSubview(continueButton)
            NSLayoutConstraint.activate([
                continueButton.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 25),
                continueButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            ])
        }
    }
    
}
