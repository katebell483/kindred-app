//
//  ViewController.swift
//  kindred-app2
//
//  Created by Katherine Bell on 11/8/17.
//  Copyright © 2017 Katherine Bell. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // These strings will be the data for the table view cells
    let animals: [String] = ["Horse", "Cow", "Camel", "Sheep", "Goat"]
    
    // These are the colors of the square views in our table view cells.
    // In a real project you might use UIImages.
    let colors = [UIColor.blue, UIColor.yellow, UIColor.magenta, UIColor.red, UIColor.brown]
    
    let cellReuseIdentifier = "cell"
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:StudentCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! StudentCell
        
        cell.myView.backgroundColor = self.colors[indexPath.row]
        cell.myCellLabel.text = self.animals[indexPath.row]
        cell.deviceCount.text = self.animals[indexPath.row]
        
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animals.count
    }

}

