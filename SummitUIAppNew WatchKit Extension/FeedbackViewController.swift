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

    @IBOutlet weak var star1: WKInterfaceButton!
    @IBOutlet weak var star2: WKInterfaceButton!
    @IBOutlet weak var star3: WKInterfaceButton!
    
    @IBOutlet weak var star4: WKInterfaceButton!
    @IBOutlet weak var star5: WKInterfaceButton!
    
    
    @IBOutlet weak var tooMuchStimButton: WKInterfaceButton!
    @IBOutlet weak var tooLittleStimButton: WKInterfaceButton!
    
    
    var feedback = Feedback()
    
    
    @IBAction func star1Clicked() {
        star1.setBackgroundImage(UIImage(systemName: "1.circle.fill"))
        star2.setBackgroundImage(UIImage(systemName:"2.circle"))
        star3.setBackgroundImage(UIImage(systemName:"3.circle"))
        star4.setBackgroundImage(UIImage(systemName:"4.circle"))
        star5.setBackgroundImage(UIImage(systemName:"5.circle"))
        feedback.rating = 1
        
    }
    @IBAction func star2Clicked() {
        star1.setBackgroundImage(UIImage(systemName: "1.circle"))
        star2.setBackgroundImage(UIImage(systemName:"2.circle.fill"))
        star3.setBackgroundImage(UIImage(systemName:"3.circle"))
        star4.setBackgroundImage(UIImage(systemName:"4.circle"))
        star5.setBackgroundImage(UIImage(systemName:"5.circle"))
        feedback.rating = 2
    }
    @IBAction func star3Clicked() {
        star1.setBackgroundImage(UIImage(systemName: "1.circle"))
        star2.setBackgroundImage(UIImage(systemName:"2.circle"))
        star3.setBackgroundImage(UIImage(systemName:"3.circle.fill"))
        star4.setBackgroundImage(UIImage(systemName:"4.circle"))
        star5.setBackgroundImage(UIImage(systemName:"5.circle"))
        feedback.rating = 3
    }
    @IBAction func star4Clicked() {
        star1.setBackgroundImage(UIImage(systemName: "1.circle"))
        star2.setBackgroundImage(UIImage(systemName:"2.circle"))
        star3.setBackgroundImage(UIImage(systemName:"3.circle"))
        star4.setBackgroundImage(UIImage(systemName:"4.circle.fill"))
        star5.setBackgroundImage(UIImage(systemName:"5.circle"))
        feedback.rating = 4
    }
    @IBAction func star5Clicked() {
        star1.setBackgroundImage(UIImage(systemName: "1.circle"))
        star2.setBackgroundImage(UIImage(systemName:"2.circle"))
        star3.setBackgroundImage(UIImage(systemName:"3.circle"))
        star4.setBackgroundImage(UIImage(systemName:"4.circle"))
        star5.setBackgroundImage(UIImage(systemName:"5.circle.fill"))
        feedback.rating = 5
    }
    
   
    
    @IBAction func SubmitClicked() {
        let submitFeedback = [
            "Rating": feedback.rating,
            "Message": feedback.feedbackMessage,
        ] as [String : Any]
        if PhoneConnection.shared.send(key: "Feedback", value: submitFeedback){
            print("feedback submitted")
            resetValues()
            successfullySent()
        }else{
            print("send failed")
        }
    }
    
    @IBAction func tooMuchStimulationClicked() {
        
        tooMuchStimButton.setBackgroundColor(UIColor.white)
        tooLittleStimButton.setBackgroundColor(UIColor.darkGray)
        feedback.feedbackMessage = "Too much stimulation"
        
    }
    
    
    @IBAction func tooLittleStimulationClicked() {
        tooLittleStimButton.setBackgroundColor(UIColor.white)
        tooMuchStimButton.setBackgroundColor(UIColor.darkGray)
        feedback.feedbackMessage = "Too little stimulation"
        
    }
    
    func successfullySent(){
        let action = WKAlertAction(title: "Ok", style: WKAlertActionStyle.default) {
                print("Ok")
            }
            presentAlert(withTitle: "Success!", message: "Your medication was successfully logged", preferredStyle: WKAlertControllerStyle.alert, actions:[action])
    }
    
    func resetValues(){
        star1.setBackgroundImage(UIImage(systemName: "1.circle"))
        star2.setBackgroundImage(UIImage(systemName:"2.circle"))
        star3.setBackgroundImage(UIImage(systemName:"3.circle"))
        star4.setBackgroundImage(UIImage(systemName:"4.circle"))
        star5.setBackgroundImage(UIImage(systemName:"5.circle"))
        feedback.rating = 0
        feedback.feedbackMessage = " "
        tooMuchStimButton.setBackgroundColor(UIColor.darkGray)
        tooLittleStimButton.setBackgroundColor(UIColor.darkGray)
        
    }
    
}
