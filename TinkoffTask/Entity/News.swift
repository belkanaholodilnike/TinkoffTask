//
//  News.swift
//  TinkoffTask
//
//  Created by Sher Locked on 04.07.2018.
//  Copyright © 2018 Sher Locked. All rights reserved.
//


import Foundation
import CoreData

class News {
    var headerText: String?
    var descriptionText: String?
    var id: String?
    var date: Date?
    var counter: Int = 0
    
    init(headerText: String?, descriptionText: String?, id: String?, date: Date?) {
        self.headerText = headerText
        self.descriptionText = descriptionText
        self.id = id
        self.date = date
    }
    
    init(object: NSManagedObject) {
        headerText = object.value(forKey: "header") as? String
        descriptionText = object.value(forKey: "descr") as? String
        id = object.value(forKey: "id") as? String
        date = object.value(forKey: "date") as? Date
        counter = object.value(forKey: "counter") as? Int ?? 0
    }
    
    func update(object: NSManagedObject, shouldUpdateCounter: Bool, shouldUpdateDescription: Bool) {
        if shouldUpdateCounter {
            object.setValue(counter, forKey: "counter")
        }
        if shouldUpdateDescription {
            object.setValue(descriptionText, forKey: "descr")
        }
        object.setValue(headerText, forKey: "header")
        object.setValue(date, forKey: "date")
        object.setValue(id, forKey: "id")
    }
}
