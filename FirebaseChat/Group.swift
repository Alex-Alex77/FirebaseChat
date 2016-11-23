//
//  Group.swift
//  FirebaseChat
//
//  Created by Alex Alexandrovych on 21/11/2016.
//  Copyright © 2016 Alex Alexandrovych. All rights reserved.
//

import Foundation

internal class Group {
    internal let id: String
    internal let name: String
    internal let creator: String
    
    init(id: String, name: String, creator: String) {
        self.id = id
        self.name = name
        self.creator = creator
    }
}
