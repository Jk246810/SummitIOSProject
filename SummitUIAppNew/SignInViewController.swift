//
//  SignInViewController.swift
//  SummitUIAppNew
//
//  Created by Jamee Krzanich on 11/17/21.
//


import UIKit
import Foundation
import FirebaseAuth
import Firebase


class SignInViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
   
    
    var user = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewDidAppear(_ animated: Bool)

    {
        super.viewDidAppear(animated)
        
//        do {
//             try Auth.auth().useUserAccessGroup("com.Jamee.SummitUIAppNew")
//           } catch let error as NSError {
//             print("Error changing user access group: %@", error)
//           }
        
        if ((user) != nil){
            print("this is the user \(user?.uid)")
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController")
            viewController.isModalInPresentation = true
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    //implement a method that recieves watch data and rejects it because not signed in
    
    //This function handles creating an account for a user that does not exist
    @IBAction func createAccountClicked(_ sender: UIButton) {
        let username = usernameField.text
        let password = passwordField.text
        if(username == "" ||  password == ""){
            return
        }
        Auth.auth().createUser(withEmail: username!, password: password!) { authResult, error in

                      guard let user = authResult?.user, error == nil else {
                          print("authentication failed")
                          print(password)
                        return
                      }
                      print("\(user.email!) created")
            
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController")
            self.present(viewController, animated: true, completion: nil)


        }
        
    }
    //this function handles sign in of currently existing user, refer to firebase documentation
    @IBAction func signInClicked(_ sender: UIButton) {
        let username = usernameField.text
        let password = passwordField.text
        Auth.auth().signIn(withEmail: username!, password: password!) { authResult, error in
            guard let user = authResult?.user, error == nil else {
                print("authentication failed")
              return
            }
            print("\(user.email!) created")
            
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController")
            viewController.isModalInPresentation = true
            self.present(viewController, animated: true, completion: nil)

        }
    }
    

}
