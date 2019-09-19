//
//  CardModel.swift
//  Shopify
//
//  Created by Hanyuan Ye on 2019-09-18.
//  Copyright © 2019 tester. All rights reserved.
//

import UIKit

struct Card {
    var image:      UIImage?
    var imageStr:   String
    var isMatched:  Bool
    var isSelected: Bool
    var isLoaded:   Bool
}

class CardModel {
    
    var numImages:  Int
    var numMatches: Int
    
    var images: [Card]
    
    init(_ numImages: Int, numMatches: Int) {
        let card = Card(image: UIImage(named: "placeholder"), imageStr: "placeholder", isMatched: false, isSelected: false, isLoaded: false)
        self.images = Array(repeating: card, count: numImages * numMatches)
        
        self.numImages  = numImages
        self.numMatches = numMatches
    }
    
    var allMatched: Bool {
        return images.allSatisfy { $0.isMatched }
    }
    
    func loadImages(completion: ((IndexPath) -> Void)? = nil) {
        NetworkController.instance.loadImages { (urls) in

            urls.prefix(self.numImages).forEach { url in
                NetworkController.instance.loadImage(url: url) { image in
                    let card = Card(image: image, imageStr: url.lastPathComponent, isMatched: false, isSelected: false, isLoaded: true)
                    var unloadedCardIndexes = self.images.enumerated().filter { !$0.element.isLoaded }.map { $0.offset }
                    
                    // Not the most efficient code but hopefully this isn't being called
                    // a million times
                    var indexes: [Int] = []
                    for _ in 0..<self.numMatches {
                        let diceRoll = Int(arc4random_uniform(UInt32(unloadedCardIndexes.count)))
                        let index    = unloadedCardIndexes[diceRoll]
                        indexes.append(index)
                        unloadedCardIndexes.remove(at: diceRoll)
                    }
                    
                    indexes.forEach { index in
                        self.images[index] = card
                        DispatchQueue.main.async {
                            completion?(IndexPath(item: index, section: 0))
                        }
                    }
                }
            }
        }
    }
}
