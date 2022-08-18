//
//  OptionsViewController.swift
//  SummitUIAppNew WatchKit Extension
//
//  Created by Jamee Krzanich on 6/29/22.
//

import Foundation
import WatchKit

class MainMenuViewController: WKInterfaceController, WKExtensionDelegate {
    var session: WKExtendedRuntimeSession!
    override func willActivate() {
        super.willActivate()
        _ = PhoneConnection.shared
    }
}
