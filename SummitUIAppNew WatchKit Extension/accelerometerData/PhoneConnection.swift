
import Foundation
import UIKit
import WatchConnectivity

class PhoneConnection: NSObject, ObservableObject, WCSessionDelegate {
    
    static let shared = PhoneConnection()
    
    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith state = \(activationState.rawValue)")
    }
    
    func send(key: String, value: Any) -> Bool {
        var isSuccess = false
        
        if WCSession.default.isReachable {
            WCSession.default.sendMessage([key: value], replyHandler: nil) { error in
                print(error)
                isSuccess = false
            }
            
            isSuccess = true
        }
        
        return isSuccess
    }
    
}

