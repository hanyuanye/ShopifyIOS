//
//  MainCollectionViewCell.swift
//  Shopify
//
//  Created by Hanyuan Ye on 2019-09-18.
//  Copyright © 2019 tester. All rights reserved.
//

import UIKit
import Cartography

class MainCollectionViewCell: UICollectionViewCell {
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    let imageView = UIImageView()
    let frontImageView = UIImageView(image: UIImage(named: "front"))
    
    var flipped: Bool {
        return isMatched || isSelected
    }
    
    var isCurrentlyFlipped: Bool = true
    
    override var isSelected: Bool {
        didSet {
            flipCard(animated: true)
        }
    }
    
    var isMatched: Bool = false {
        didSet {
            layer.borderWidth = isLoaded && isMatched ? 5.0 : 0
            layer.borderColor = isLoaded && isMatched ? UIColor.green.cgColor : UIColor.clear.cgColor
            flipCard(animated: false)
        }
    }
    
    var isLoaded: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    init() {
        super.init(frame: .zero)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        backgroundColor = .white
        
        imageView.contentMode = .scaleAspectFill
        
        addSubview(imageView)
        constrain(self, imageView) { cell, image in
            image.edges == cell.edges
        }
        
        frontImageView.contentMode = .scaleAspectFill
        
        addSubview(frontImageView)
        constrain(self, frontImageView) { cell, image in
            image.edges == cell.edges
        }
    }
    
    func flipCard(animated: Bool = false) {
        guard isCurrentlyFlipped != flipped else { return }
        
        isCurrentlyFlipped = flipped
        let fromView = flipped ? frontImageView : imageView
        let toView   = flipped ? imageView : frontImageView
        
        let flipDirection: UIView.AnimationOptions = flipped ? .transitionFlipFromRight : .transitionFlipFromLeft
        let options: UIView.AnimationOptions = [flipDirection, .showHideTransitionViews]
        let duration: Double = animated ? 0.6 : 0
        UIView.transition(from: fromView, to: toView, duration: duration, options: options, completion: nil)
    }
}
