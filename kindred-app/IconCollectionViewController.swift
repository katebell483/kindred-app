//
//  IconCollectionViewController.swift
//  kindred-app2
//
//  Created by Katherine Bell on 11/17/17.
//  Copyright © 2017 Katherine Bell. All rights reserved.
//

import UIKit

class IconCollectionViewController: UICollectionViewController {
    
    private let reuseIdentifier = "IconCell"
    
    var icons = [UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.icons = [UIImage(named:"airplane")!,
                UIImage(named:"toilet-paper")!,
                UIImage(named:"water")!,
                UIImage(named:"leaf")!,
                UIImage(named:"lily-1")!,
                UIImage(named:"alarm-clock")!,
                UIImage(named: "breakfast")!,
                UIImage(named: "dinner")!,
                UIImage(named: "improvement")!,
                UIImage(named: "list")!,
                UIImage(named: "cosmetics")!,
                UIImage(named:"customer-problem")!]

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(icons.count)
        return icons.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:IconCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! IconCollectionCell
        
        cell.iconImage.image = icons[indexPath.row]

        
        return cell
    }

    // MARK: UICollectionViewDelegate

  

}
