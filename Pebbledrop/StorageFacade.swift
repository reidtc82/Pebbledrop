//
//  StorageFacade.swift
//  Pebbledrop
//
//  Created by Reid Case on 2/22/18.
//  Copyright © 2018 Reid Case. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

class StorageFacade {
    static let sharedInstance = StorageFacade()
    let TWENTYFOURHOURS:Double = -60*60*24
    
    func getPebbles(around location:CLLocation) -> [Pebble] {
        let records = getRecords(around: location)
        var pebbles:[Pebble] = []
        
        for rec in records {
            let tempPebble = Pebble(message: rec.value(forKey: "message") as! String, locationOffset: 1, at: rec.value(forKey: "location") as! CLLocation, imageURL: NSURL(), image: rec.value(forKey: "image") as! UIImage)
            
            pebbles.append(tempPebble)
        }
        
        
    }
    
    func getRecords(around location:CLLocation) -> [CKRecord] {
        let container = CKContainer.default()
        let privateDatabase = container.privateCloudDatabase
        let radius = 100;
        
        var predicateLoc:NSPredicate? = nil
        var predicateTime:NSPredicate? = nil
        var records:[CKRecord] = []
         //meters
        
        predicateLoc = NSPredicate(format: "distanceToLocation:fromLocation:(location, %@) < %f", location, radius)
        predicateTime  = NSPredicate(format: "creationDate > %@",NSDate(timeInterval: -86400, since: NSDate() as Date)) as NSPredicate
        
        let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateLoc!, predicateTime!])
        
        let query = CKQuery(recordType: "pebble", predicate: compound)
        
        privateDatabase.perform(query, inZoneWith: nil) { (results, error) -> Void in
            if error != nil {
                print(error ?? "didnt work")
            }
            else {
                print("---------LOCAL PEBBLES--------")
                print(results ?? "did work")
                print("-------END LOCAL PEBBLES------")
                print(NSDate(timeInterval: self.TWENTYFOURHOURS, since: NSDate() as Date))
                /**for result in results! {
                    self.arrNotes.append(result as! CKRecord)
                }
                
                OperationQueue.main.addOperation({ () -> Void in
                    self.tblNotes.reloadData()
                    self.tblNotes.hidden = false
                })**/
                records = results!
            }
        }
        return records
    }
    
    func drop(this pebble:Pebble)
    {
        print("+++++++++++\(pebble.message)")
        let timestampAsString = String(format: "%f", NSDate.timeIntervalSinceReferenceDate)
        let timestampParts = timestampAsString.split(separator: ".")
        print(timestampParts)
        let noteID = CKRecordID(recordName: String(timestampParts[0]))
        
        let noteRecord = CKRecord(recordType: "pebble", recordID: noteID)
        
        noteRecord.setObject(pebble.message as CKRecordValue, forKey: "message")
        noteRecord.setObject(pebble.location as CKRecordValue, forKey: "location")
        noteRecord.setObject(pebble.locationOffset as CKRecordValue, forKey: "locationOffset")
        noteRecord.setObject(pebble.location.altitude as CKRecordValue, forKey: "altitude")
        
        let imageAsset = CKAsset(fileURL: pebble.imageURL! as URL)
        noteRecord.setObject(imageAsset, forKey: "pebbleImage")
        
        let container = CKContainer.default()
        let publicDatabase = container.privateCloudDatabase //Ah I did set it up as private. Make sure this is changed for final release.
        
        publicDatabase.save(noteRecord, completionHandler: { (record, error) -> Void in
            if (error != nil) {
                print(error ?? "There was an error")//I wonder why it didnt error
            }//have an else to set a timeout for posting more within a few seconds. Dont wnt spam and probably also want some sort of confirmation
        })
    }
}
