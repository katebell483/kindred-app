//
//  AddStudentView.swift
//  kindred-app2
//
//  Created by Katherine Bell on 11/8/17.
//  Copyright © 2017 Katherine Bell. All rights reserved.
//

import UIKit

class AddStudentView: UIViewController {
    
    
    @IBOutlet weak var studentName: UITextField!
    @IBOutlet weak var studentNotes: UITextField!
    @IBOutlet weak var buttonName: UITextField!
    @IBOutlet weak var buttonID: UITextField!
    @IBOutlet weak var buttonMsg: UITextField!
    
    struct PostData {
        let studentName: String
        let studentNotes: String
        let buttonName: String
        let buttonID: String
        let buttonMsg: String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func AddButton(_ sender: Any) {
        
        // require text fields to be filled
        // TODO: give some kind of visual feedback here
        if(studentName.text?.isEmpty ?? true ||
            buttonName.text?.isEmpty ?? true ||
            buttonID.text?.isEmpty ?? true ||
            buttonMsg.text?.isEmpty ?? true) {
            print("empty fields found. exiting")
            return;
        }
        
        // send http post request
        //var postParams;
        let url = URL(string: "http://127.0.0.1:5000/device");
        let postData: [String: String] = [
            "student_name": studentName.text!,
            "profile_type": studentNotes.text!,
            "device_id": buttonID.text!,
            "service_id": buttonName.text!,
            "read_msg": buttonMsg.text!
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: postData, options: [])
        
        httpPost(jsonData: jsonData!, url: url!);

        // on receipt show alert
        let alertController = UIAlertController(title: "Kindred App", message:
            "Button Added!", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
        
        // clear button text fields & clear focus
        buttonName.text =  nil;
        buttonID.text =  nil;
        buttonMsg.text =  nil;
        
        // TODO: clear cursor
        
    }
    
    func httpPost(jsonData: Data, url: URL) {
        if !jsonData.isEmpty {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            
            URLSession.shared.getAllTasks { (openTasks: [URLSessionTask]) in
                NSLog("open tasks: \(openTasks)")
            }
            
            /*
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (responseData: Data?, response: URLResponse?, error: Error?) in
                NSLog("\(response)")
            })
            task.resume()
            */
            
            print("ALL GOOD");
        }
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
