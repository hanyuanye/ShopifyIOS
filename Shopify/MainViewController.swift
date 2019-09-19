//
//  MainViewController.swift
//  Shopify
//
//  Created by Hanyuan Ye on 2019-09-18.
//  Copyright © 2019 tester. All rights reserved.
//

import UIKit
import Cartography

class MainViewController: UIViewController {
    static let numMatches = 2
    let cellReuseIdentifier = "Cell"
    
    let model = CardModel(15, numMatches: MainViewController.numMatches)
    let collectionView: UICollectionView
    
    let hapticNotification = UINotificationFeedbackGenerator()
    
    var currentSelections: [(card: Card, indexPath: IndexPath)] = []
    
    var timerCounter = 0
    var timer: Timer? = nil
    
    var pairCounter = 0
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .init(width: 100, height: 100)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        
        setupCollectionView()
        setupNavigation()
        
        model.loadImages { indexPath in
            /* Model notifying vc that indexPath is ready to be reloaded */
            self.collectionView.reloadItems(at: [indexPath])
        }
    }

    func setupCollectionView() {
        collectionView.allowsMultipleSelection = true
        collectionView.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        
        collectionView.dataSource = self
        collectionView.delegate   = self
        
        view.addSubview(collectionView)
        
        constrain(view, collectionView) { view, collectionView in
            collectionView.edges == view.edges
        }
    }
    
    func setupNavigation() {
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.titleTextAttributes = .init([.foregroundColor : UIColor.white])
        
        timer = Timer(timeInterval: 1, repeats: true) { (timer) in
            self.timerCounter += 1
            self.navigationItem.title = String(self.timerCounter) + " Seconds, Pairs: " + String(self.pairCounter)
        }
        
        RunLoop.current.add(timer!, forMode: .default)
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as? MainCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let card = model.images[indexPath.item]
        
        cell.image      = card.image
        cell.isMatched  = card.isMatched
        cell.isSelected = card.isSelected
        cell.isLoaded   = card.isLoaded
        
        return cell
    }
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let card = model.images[indexPath.item]
        
        if !card.isLoaded || card.isMatched || card.isSelected {
            hapticNotification.notificationOccurred(.error)
            return false
        }
        
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        func reset() {
            currentSelections.forEach { selection in
                self.model.images[selection.indexPath.item].isSelected = false
            }
            
            let indexPaths = currentSelections.map { $0.indexPath }
            
            collectionView.reloadItems(at: indexPaths)
            
            currentSelections.removeAll()
        }
        
        func checkMatchFound() {
            guard currentSelections.count >= MainViewController.numMatches else { return }
            
            hapticNotification.notificationOccurred(.success)
            pairCounter += 1
            currentSelections.forEach { selection in
                let indexPath = selection.indexPath
                model.images[indexPath.item].isMatched = true
            }
            
            if model.allMatched {
                let congratsStr = "Congratulations! Your final score is: " + String(timerCounter) + "!"
                let alertController = UIAlertController(title: "title", message: congratsStr, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                
                self.present(alertController, animated: true, completion: nil)
                
                timer?.invalidate()
            }
            
            reset()
        }
        
        model.images[indexPath.item].isSelected = true
        let card = model.images[indexPath.item]
        currentSelections.append((card, indexPath))
        
        guard !(currentSelections.count == 1) else {
            // Maybe they want to play where they press a card and it gets matched?!?
            if currentSelections.count == MainViewController.numMatches {
                checkMatchFound()
            }
            return
        }
        
        let aSelection = currentSelections.first!
        guard aSelection.card.imageStr == card.imageStr else {
            // No match so we reset
            
            hapticNotification.notificationOccurred(.error)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: reset)
            return
        }
        
        checkMatchFound()
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let cellWidth   = screenWidth / 3.2
        let cellHeight  = screenWidth / 3.0
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
