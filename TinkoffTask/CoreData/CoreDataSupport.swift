//
//  CoreDataSupport.swift
//  TinkoffTask
//
//  Created by Sher Locked on 08.07.2018.
//  Copyright © 2018 Sher Locked. All rights reserved.
//

import UIKit
import CoreData

class CoreDataSupport {
    
    static func getContext() -> NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    static func fetchAllNews() -> [News] {
        return fetchNews(with: nil).sorted(by: { $0.date?.timeIntervalSince1970 ?? 0 > $1.date?.timeIntervalSince1970 ?? 0 })
    }
    
    static func fetchNews(with id: String) -> News? {
        let predicate = NSPredicate(format: "id = %@", id)
        let news = fetchNews(with: predicate)
        return news.first
    }
    
    static func fetchNews(with ids: [String]) -> [News] {
        return ids.map { fetchNews(with: $0) }.compactMap { $0 }
    }
    
    static func save(news: [News], shouldUpdateCounter: Bool, shouldUpdateDescription: Bool) {
        guard let context = getContext() else {
            return
        }
        for newsEntity in news {
            let updateResult = update(news: newsEntity, shouldUpdateCounter: shouldUpdateCounter, shouldUpdateDescription: shouldUpdateDescription)
            if !updateResult {
                let entity = NSEntityDescription.entity(forEntityName: "NewsModel", in: context)
                let newsObject = NSManagedObject(entity: entity!, insertInto: context)
                newsEntity.update(object: newsObject, shouldUpdateCounter: shouldUpdateCounter, shouldUpdateDescription: shouldUpdateDescription)
            }
        }
        do {
            try context.save()
        }
        catch {
            print("Can't save to Core Data")
        }
    }
    
    static func deleteAllData(except news: [News] = []) {
        guard let context = getContext() else {
            return
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NewsModel")
        
        do {
            let results = try context.fetch(fetchRequest)
            let exceptIds = news.map { $0.id }
            for object in results
            {
                if let objectData = object as? NSManagedObject {
                    let savedNews = News(object: objectData)
                    if exceptIds.contains(savedNews.id) {
                        continue
                    }
                    context.delete(objectData)
                }
            }
        } catch {
            print("Can't reset core data")
        }
    }
    
    @discardableResult
    static func update(news: News, shouldUpdateCounter: Bool, shouldUpdateDescription: Bool) -> Bool {
        guard let context = getContext(), let id = news.id else {
            return false
        }
        let predicate = NSPredicate(format: "id = %@", id)
        guard let record = fetchManagedObjects(with: predicate).first else {
            return false
        }
        news.update(object: record, shouldUpdateCounter: shouldUpdateCounter, shouldUpdateDescription: shouldUpdateDescription)
        do {
            try context.save()
            return true
        }
        catch {
            print("Can't update object in Core Data")
            return false
        }
    }
    
    private static func fetchNews(with predicate: NSPredicate?) -> [News] {
        let records = fetchManagedObjects(with: predicate)
        let fetchedNews = records.map { object -> News in
            return News(object: object)
        }
        return fetchedNews
    }
    
    private static func fetchManagedObjects(with predicate: NSPredicate?) -> [NSManagedObject] {
        guard let context = getContext() else {
            return []
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NewsModel")
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        
        var result: [NSManagedObject] = []
        
        do {
            let records = try context.fetch(fetchRequest)
            if let records = records as? [NSManagedObject] {
                result = records
            }
        }
        catch {
            print("Unable fo fetch records from Core Data.")
        }
        return result
    }
}
