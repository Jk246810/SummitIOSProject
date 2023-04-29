//
//  Dependencies.swift
//  SummitUIAppNewTests
//
//  Created by Jamee Krzanich on 7/29/22.
//
import Foundation
import Swinject

class Dependencies {
    static let container: Container = {
       let container = Container()

        container.register(InjectableNotifications.self) { _ in
            InjectableNotifications.default
        }.inObjectScope(.container)
        
        container.register(CredentialsValidator.self) { resolver in
            SimpleCredentialsValidator(
                injectableNotifications: resolver.resolve(InjectableNotifications.self)!)
        }.inObjectScope(.container)

        return container
    }()
}
