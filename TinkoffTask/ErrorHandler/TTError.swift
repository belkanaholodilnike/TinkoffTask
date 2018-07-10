//
//  TTError.swift
//  TinkoffTask
//
//  Created by Sher Locked on 07.07.2018.
//  Copyright © 2018 Sher Locked. All rights reserved.
//

import Foundation

enum ErrorType: String {
    case requestCreationError = "Request creation error"
    case jsonSerializationError = "JSON serialization error"
    case unknownError = "unknown error"
}

struct TTError {
    
    var type: ErrorType?
    var description: String?
    
    init(type: ErrorType) {
        self.type = type
    }
    
    init(error: Error) {
        self.description = error.localizedDescription
    }
    
    func getDescription() -> String? {
        if let description = description {
            return description
        }
        
        if let type = type {
            return type.rawValue
        }
        
        return nil
    }
}
