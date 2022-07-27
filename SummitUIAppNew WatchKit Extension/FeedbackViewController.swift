//
//  FeedbackViewController.swift
//  SummitUIAppNew WatchKit Extension
//
//  Created by Jamee Krzanich on 6/29/22.
//

import Foundation
import WatchKit
import UIKit

struct Feedback{
    var feedbackMessage = ""
    var rating = 0
}

class FeedbackViewController: WKInterfaceController {
    var connector = PhoneConnection()

    @IBOutlet weak var star1: WKInterfaceButton!
    @IBOutlet weak var star2: WKInterfaceButton!
    @IBOutlet weak var star3: WKInterfaceButton!
    
    @IBOutlet weak var star4: WKInterfaceButton!
    @IBOutlet weak var star5: WKInterfaceButton!
    
    
    @IBOutlet weak var feedbackMessageLabel: WKInterfaceTextField!
    var feedback = Feedback()
    
    
    @IBAction func star1Clicked() {
        star1.setBackgroundImage(UIImage(systemName: "star.fill"))
        star2.setBackgroundImage(UIImage(systemName:"star"))
        star3.setBackgroundImage(UIImage(systemName:"star"))
        star4.setBackgroundImage(UIImage(systemName:"star"))
        star5.setBackgroundImage(UIImage(systemName:"star"))
        feedback.rating = 1
        
    }
    @IBAction func star2Clicked() {
        star1.setBackgroundImage(UIImage(systemName: "star.fill"))
        star2.setBackgroundImage(UIImage(systemName:"star.fill"))
        star3.setBackgroundImage(UIImage(systemName:"star"))
        star4.setBackgroundImage(UIImage(systemName:"star"))
        star5.setBackgroundImage(UIImage(systemName:"star"))
        feedback.rating = 2
    }
    @IBAction func star3Clicked() {
        star1.setBackgroundImage(UIImage(systemName: "star.fill"))
        star2.setBackgroundImage(UIImage(systemName:"star.fill"))
        star3.setBackgroundImage(UIImage(systemName:"star.fill"))
        star4.setBackgroundImage(UIImage(systemName:"star"))
        star5.setBackgroundImage(UIImage(systemName:"star"))
        feedback.rating = 3
    }
    @IBAction func star4Clicked() {
        star1.setBackgroundImage(UIImage(systemName: "star.fill"))
        star2.setBackgroundImage(UIImage(systemName:"star.fill"))
        star3.setBackgroundImage(UIImage(systemName:"star.fill"))
        star4.setBackgroundImage(UIImage(systemName:"star.fill"))
        star5.setBackgroundImage(UIImage(systemName:"star"))
        feedback.rating = 4
    }
    @IBAction func star5Clicked() {
        star1.setBackgroundImage(UIImage(systemName: "star.fill"))
        star2.setBackgroundImage(UIImage(systemName:"star.fill"))
        star3.setBackgroundImage(UIImage(systemName:"star.fill"))
        star4.setBackgroundImage(UIImage(systemName:"star.fill"))
        star5.setBackgroundImage(UIImage(systemName:"star.fill"))
        feedback.rating = 5
    }
    
    @IBAction func MessageTextFieldInput(_ value: NSString?) {
        feedback.feedbackMessage = (value ?? "") as String 
    }
    
    @IBAction func SubmitClicked() {
        let submitFeedback = [
            "Rating": feedback.rating,
            "Message": feedback.feedbackMessage,
        ] as [String : Any]
        if self.connector.send(key: "Feedback", value: submitFeedback){
            print("feedback submitted")
        }else{
            print("send failed")
        }
        self.feedbackMessageLabel.setText("")
    }
    
    
    
    
}
