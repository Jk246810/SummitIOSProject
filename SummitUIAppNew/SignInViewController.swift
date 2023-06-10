//
//  SignInViewController.swift
//  SummitUIAppNew
//
//  Created by Jamee Krzanich on 11/17/21.
//


import UIKit
import Foundation
import FirebaseAuth




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

        if ((user) != nil){
           // print("this is the user \(user?.uid)")
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController")
            if #available(iOS 13.0, *) {
                viewController.isModalInPresentation = true
            } else {
                // Fallback on earlier versions
            }
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    //This function handles creating an account for a user that does not exist
    @IBAction func createAccountClicked(_ sender: UIButton) {
        let username = usernameField.text
        let password = passwordField.text
        if(username == "" ||  password == ""){
            return
        }
        Auth.auth().createUser(withEmail: username!, password: password!) { authResult, error in

                      guard let user = authResult?.user, error == nil else {
                          self.presentFailedLoginScreen()
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
                self.presentFailedLoginScreen()
              return
            }
            print("\(user.email!) created")
            
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController")
            if #available(iOS 13.0, *) {
                viewController.isModalInPresentation = true
            } 
            self.present(viewController, animated: true, completion: nil)

        }
    }
    
    func presentFailedLoginScreen(){
        let alert = UIAlertController(title: "Unable to Login", message: "Login Failed. Check network connection or credentials", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
        NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    

}
