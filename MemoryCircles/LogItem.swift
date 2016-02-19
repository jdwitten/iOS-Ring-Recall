//
//  LogItem.swift
//  MemoryCircles
//
//  Created by Jonathan Witten on 12/30/15.
//  Copyright © 2015 Jonathan Witten. All rights reserved.
//

import Foundation
import CoreData




/*
This is a class that helps with the data model associated with the game
The log item is a subclass of NSManaged Object and serves as a record which keeps track 
of the user's High Score
*/
class LogItem: NSManagedObject {
    
    @NSManaged var title: String //An identifier when accessing CoreData
    @NSManaged var score: Int16 //The user's High Score
    
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, title: String, score: Int16) -> LogItem {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("LogItem", inManagedObjectContext: moc) as! LogItem
        newItem.title = title
        newItem.score = score
        
        return newItem
    }
}
