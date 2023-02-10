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
    var rating = true
}

class FeedbackViewController: WKInterfaceController {


    
    
    @IBOutlet weak var tooMuchStimButton: WKInterfaceButton!
    @IBOutlet weak var tooLittleStimButton: WKInterfaceButton!
    
    
    var feedback = Feedback()
   
    
    @IBAction func SubmitClicked() {
        let submitFeedback = [
            "Good": feedback.rating,
            "Message": feedback.feedbackMessage,
        ] as [String : Any]
        if(feedback.rating == false && feedback.feedbackMessage != ""){
            if PhoneConnection.shared.send(key: "Feedback", value: submitFeedback){
                print("feedback submitted")
                resetValues()
                successfullySent()
            }else{
                print("send failed")
            }
        }else{
            notifyInvalidValues()
        }
        
    }
    @IBOutlet weak var goodButton: WKInterfaceButton!
    
    @IBOutlet weak var badButton: WKInterfaceButton!
    
    @IBAction func GoodClicked() {
        goodButton.setBackgroundColor(UIColor.white)
        badButton.setBackgroundColor(UIColor.darkGray)
        feedback.rating = true
    }
    
    @IBAction func badClicked() {
        badButton.setBackgroundColor(UIColor.white)
        goodButton.setBackgroundColor(UIColor.darkGray)
        feedback.rating = false
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
            presentAlert(withTitle: "Success!", message: "Your feedback was successfully logged", preferredStyle: WKAlertControllerStyle.alert, actions:[action])
    }
    
    func notifyInvalidValues(){
        let action = WKAlertAction(title: "Ok", style: WKAlertActionStyle.default) {
                print("Ok")
            }
            presentAlert(withTitle: "Invalid Entry", message: "You must submit notes if your rating is 'Bad'", preferredStyle: WKAlertControllerStyle.alert, actions:[action])
    }
    func resetValues(){
        
        feedback.rating = true
        feedback.feedbackMessage = " "
        tooMuchStimButton.setBackgroundColor(UIColor.darkGray)
        tooLittleStimButton.setBackgroundColor(UIColor.darkGray)
        goodButton.setBackgroundColor(UIColor.darkGray)
        badButton.setBackgroundColor(UIColor.darkGray)
        
    }
    
}
