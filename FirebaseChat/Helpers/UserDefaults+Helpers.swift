//
//  UserDefaults+Helpers.swift
//  FirebaseChat
//
//  Created by Alex Alexandrovych on 29/11/2016.
//  Copyright © 2016 Alex Alexandrovych. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    enum UserDefaultsKeys: String {
        case isLoggedIn
    }
    
    func setIsLoggedIn(_ value: Bool) {
        set(value, forKey: UserDefaultsKeys.isLoggedIn.rawValue)
        synchronize()
    }
    
    func isLoggedIn() -> Bool {
        return bool(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
    }
}
