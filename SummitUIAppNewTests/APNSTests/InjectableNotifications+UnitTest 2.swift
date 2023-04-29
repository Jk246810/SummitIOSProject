//
//  InjectableNotifications+UnitTest.swift
//  SummitUIAppNewTests
//
//  Created by Jamee Krzanich on 7/29/22.
//

import Foundation

@testable import SummitUIAppNew

extension InjectableNotifications {
    static func forUnitTests() -> InjectableNotifications {
        InjectableNotifications(
            userLoggedIn: Notification.Name(rawValue: UUID().uuidString),
            userLoggedOut: Notification.Name(rawValue: UUID().uuidString))
    }
}
