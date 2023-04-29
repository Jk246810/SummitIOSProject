//
//  CredentialsValidator.swift
//  SummitUIAppNewTests
//
//  Created by Jamee Krzanich on 7/29/22.
//

import Foundation

protocol CredentialsValidator {
    func validate(username: String?, onCompletion: @escaping ((_ user: User?) -> Void))
}
