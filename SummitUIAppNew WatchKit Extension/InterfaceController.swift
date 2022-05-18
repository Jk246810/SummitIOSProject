//
//  InterfaceController.swift
//  SummitUIAppNew WatchKit Extension
//
//  Created by Jamee Krzanich on 11/17/21.
//

import WatchKit
import Foundation
import Firebase


class InterfaceController: WKInterfaceController {
    var usernameText: String = ""
    var passwordText: String = ""
    
    var user = Auth.auth().currentUser
    override func awake(withContext context: Any?) {
        
       
        
        
    }
    override func didAppear(){
        if ((user) != nil){
            self.pushController(withName: "MedicationLogController", context: nil)
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        
    }
    
    override func didDeactivate() {
        
        // This method is called when watch view controller is no longer visible
    }
    
    @IBAction func usernameTextField(_ value: NSString?) {
        if(value != nil){
            usernameText = value! as String
            print("this is the username: " + usernameText)
        }
    }
    
    @IBAction func passwordTextField(_ value: NSString?) {
        if(value != nil){
            passwordText = value! as String
        }
    }
    
    
    
    @IBAction func signInActivated() {
        
        Auth.auth().signIn(withEmail: usernameText, password: passwordText) { authResult, error in
            guard let user = authResult?.user, error == nil else {
                print("authentication failed")
              return
            }
            print("\(user.email!) signed in")
            self.pushController(withName: "MedicationLogController", context: nil)
            

        }
    }
    

}
