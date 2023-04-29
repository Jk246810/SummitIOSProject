//
//  InjectableNotifications.swift
//  SummitUIAppNewTests
//
//  Created by Jamee Krzanich on 7/29/22.
//

import Foundation


import Foundation

struct InjectableNotifications {
    let userLoggedIn: Notification.Name
    let userLoggedOut: Notification.Name
}

extension InjectableNotifications {
    static let `default` = InjectableNotifications(
        userLoggedIn: Notification.Name(rawValue: "userLoggedIn"),
        userLoggedOut: Notification.Name(rawValue: "userLoggedOut"))
}

