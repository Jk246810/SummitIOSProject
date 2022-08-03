//
//  SimpleCredentialsValidator.swift
//  SummitUIAppNewTests
//
//  Created by Jamee Krzanich on 7/29/22.
//

import Foundation

class SimpleCredentialsValidator: CredentialsValidator {
    private let injectableNotifications: InjectableNotifications
    
    init(injectableNotifications: InjectableNotifications) {
        self.injectableNotifications = injectableNotifications
    }

    func validate(username: String?, onCompletion: @escaping ((User?) -> Void)) {
        guard let definedUsername = username else {
            onCompletion(nil)
            return
        }

        let user = User(username: definedUsername)
        onCompletion(user)
        NotificationCenter.default.post(name: injectableNotifications.userLoggedIn, object: user)
    }
}
