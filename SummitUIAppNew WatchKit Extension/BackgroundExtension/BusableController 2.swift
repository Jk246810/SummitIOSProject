//
//  BusableController.swift
//  SummitUIAppNew WatchKit Extension
//
//  Created by Jamee Krzanich on 10/21/22.
//

import Foundation
import UIKit
import WatchKit

// MARK: - Declerations
class BusableController: WKInterfaceController{
    typealias Subs = KeyValuePairs<Bus.Events, (Notification) -> Void>
    // Stub, should be overriden
    var SubscriptionEvents: Subs { get { return [:] } }
    
    private var Desubsrcibers: [Bus.Unsubscriber?] = []
}

// MARK: - Bus Sub/De-sub
extension BusableController {
    private func register() {
        print("BusableController: registering bus events")
        for sub in self.SubscriptionEvents {
            self.Desubsrcibers.append(Bus.shared.on(event: sub.key, cb: sub.value))
        }
    }
    
    private func deregister() {
        print("BusableController: removing bus events")
        let cnt = self.Desubsrcibers.count
        for i in 0 ..< cnt {
            var m = self.Desubsrcibers[i]
            m?()
            self.Desubsrcibers[i] = nil
            m = nil
        }
    }
}

// MARK: - Life Cycle
extension BusableController {
    
    override func willActivate() {
        super.willActivate()
        print("view will activate")
        register()
    }
    
    override func willDisappear() {
        super.willDisappear()
        deregister()
    }
}

