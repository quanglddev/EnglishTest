//
//  Boxes.swift
//  EnglishTest
//
//  Created by QUANG on 2/23/17.
//  Copyright © 2017 QUANG INDUSTRIES. All rights reserved.
//

import UIKit
import os.log

class Boxes: NSObject, NSCoding  {
    
    //MARK: Types
    struct PropertyKey {
        static let name = "name"
        static let cards = "cards"
    }
    
    //MARK: Properties
    var name: String
    var cards: [StructOxfordData]
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("Boxes")
    
    //MARK: Initialization
    init?(name: String, cards: [StructOxfordData]) {
        
        // Initialization should fail if there is no name or if the rating is negative.
        guard !name.isEmpty else {
            return nil
        }
        
        self.name = name
        self.cards = cards
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(cards, forKey: PropertyKey.cards)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let cards = aDecoder.decodeObject(forKey: PropertyKey.cards) as? [StructOxfordData] else {
            os_log("Unable to decode the cards.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // Must call designated initializer.
        self.init(name: name, cards: cards)
    }
}
