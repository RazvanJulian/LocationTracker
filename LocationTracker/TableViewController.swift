//
//  TableViewController.swift
//  LocationTracker
//
//  Created by Razvan Julian on 01/06/2018.
//  Copyright © 2018 Razvan Julian. All rights reserved.
//

import UIKit

var places = [Dictionary <String, Any>()]
var activePlace = -1

class TableViewController: UITableViewController {
    
    @IBOutlet var cleanBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.title = "Routes"

        activePlace = -1
        
        tableView.reloadData()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        if places.count == 1 && places[0].count == 0 {
            places.remove(at: 0)
        }
        
        for (index, place) in places.enumerated() {
            
            if "\(String(describing: place["title"]))" == "" {
                print(place)
                places.remove(at: index)
            }
        }
        
        activePlace = -1
        tableView.reloadData()
    }
    
    
    @IBAction func cleanList(_ sender: UIBarButtonItem) {
        
        places.removeAll()
        tableView.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return places.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        // Configure the cell...
        
        let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "Cell")
        
        if places[indexPath.row]["title"] != nil {
            
            cell.textLabel?.text = places[indexPath.row]["title"] as? String
            cell.detailTextLabel?.text = places[indexPath.row]["time"] as? String
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        activePlace = indexPath.row
        performSegue(withIdentifier: "toMap", sender: nil)
    }
 
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            // Delete the row from the data source
            
            places.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
        
    }
    

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        
    }
 

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
