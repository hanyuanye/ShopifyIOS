//
//  NetworkController.swift
//  Shopify
//
//  Created by Hanyuan Ye on 2019-09-18.
//  Copyright © 2019 tester. All rights reserved.
//

import UIKit

class NetworkController {
    static let instance = NetworkController()
    
    let url = URL(string: "https://shopicruit.myshopify.com/admin/products.json?page=1&access_token=c32313df0d0ef512ca64d5b336a0d7c6")
    
    func loadImages(completion: @escaping (([URL]) -> Void)) {
        guard let url = url else {
            completion([])
            return
        }
        
        let session = URLSession(configuration: .ephemeral)
        let task = session.dataTask(with: url) { data, response, error in
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                    // response failed
                    // Probably should implement some elaborate error alert but for
                    // the purpose of this, lets just fail
                    fatalError("JSON query failed")
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []),
                  let dict = json as? [String : Any],
                  let products = dict["products"] as? [[String : Any]] else
            {
                // Similar reasoning as above
                fatalError("Json serialization failed")
            }
            
            let images = products.compactMap { product -> URL? in
                let imageData = product["image"] as? [String : Any]
                let imageSrc  = imageData?["src"] as? String
                return imageSrc != nil ? URL(string: imageSrc!) : nil
            }
            
            completion(images)
        }
        
        task.resume()
    }
    
    func loadImage(url: URL, completion: @escaping ((UIImage?) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async {
            let imageData = try? Data(contentsOf: url)
            let image = imageData != nil ? UIImage(data: imageData!) : nil
            completion(image)
        }
    }
}
