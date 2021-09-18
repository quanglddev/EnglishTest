//
//  OxfordGetData.swift
//  EnglishTest
//
//  Created by QUANG on 2/23/17.
//  Copyright © 2017 QUANG INDUSTRIES. All rights reserved.
//

import UIKit
import SwiftyJSON
import os.log

class OxfordGetData {
    var cards = [StructOxfordData]()
    var boxes = [Boxes]()
    
    let defaults = UserDefaults.standard
    
    struct defaultsKeys {
        static let taskTerminated = "taskTerminated"
    }
    
    let appId = "4b74b880"
    let appKey = "cd6cf2eb42ba48ade5fed8a2c4a9cbbe"
    let language = "en"
    
    func getOxfordDataFor(box name: String, for word: String, count: Int) {
        
        var definition: String = ""
        var example: String = ""
        var lexicalCategory: String = ""
        var phoneticSpelling: String = ""
        var audioFile: String = ""
        
        let word_id = word.lowercased() //word id is case sensitive and lowercase is required
        let url = URL(string: "https://od-api.oxforddictionaries.com:443/api/v1/entries/\(language)/\(word_id)")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(appId, forHTTPHeaderField: "app_id")
        request.addValue(appKey, forHTTPHeaderField: "app_key")
        
        let session = URLSession.shared
        _ = session.dataTask(with: request, completionHandler: { data, response, error in
            if let _ = response, let data = data {
                //print(response)
                //print(jsonData)
                
                let json = JSON(data: data)
                
                if let gotDefinition = json["results"][0]["lexicalEntries"][0]["entries"][0]["senses"][0]["definitions"][0].string {
                    print(gotDefinition)
                    definition = gotDefinition
                }
                else {
                    if let gotDefinition = json["results"][0]["lexicalEntries"][1]["entries"][0]["senses"][0]["definitions"][0].string {
                        definition = gotDefinition
                    }
                    else {
                        definition = "No definition found. 😬"
                    }
                }
                
                if let gotExample = json["results"][0]["lexicalEntries"][0]["entries"][0]["senses"][0]["examples"][0]["text"].string {
                    print(gotExample)
                    example = gotExample
                }
                else {
                    if let gotExample = json["results"][0]["lexicalEntries"][1]["entries"][0]["senses"][0]["examples"][0]["text"].string {
                        print(gotExample)
                        example = gotExample
                    }
                    else {
                        example = "No example found. 😬"
                    }
                }
                
                if let gotLexicalCategory = json["results"][0]["lexicalEntries"][0]["lexicalCategory"].string {
                    print(gotLexicalCategory)
                    lexicalCategory = gotLexicalCategory
                }
                else {
                    lexicalCategory = "No lexical category found. 😬"
                }
                
                if let gotPhoneticSpelling = json["results"][0]["lexicalEntries"][0]["pronunciations"][0]["phoneticSpelling"].string {
                    print(gotPhoneticSpelling)
                    phoneticSpelling = gotPhoneticSpelling
                }
                else {
                    phoneticSpelling = "No phonetic spelling found. 😬"
                }
                
                if let gotAudioFile = json["results"][0]["lexicalEntries"][0]["pronunciations"][1]["audioFile"].string {
                    print(gotAudioFile)
                    audioFile = gotAudioFile
                    
                }
                else {
                    if let gotAudioFile = json["results"][0]["lexicalEntries"][0]["pronunciations"][0]["audioFile"].string {
                        print(gotAudioFile)
                        audioFile = gotAudioFile
                    }
                    else {
                        audioFile = "No audio file found. 😬"
                    }
                }
                
                if self.defaults.bool(forKey: defaultsKeys.taskTerminated) {
                    self.cards.removeAll()
                    self.saveCards()
                }
                else {
                    if let savedCards = self.loadCards() {
                        self.cards = savedCards
                    }
                }
                
                if self.cards.count > count {
                    self.cards.removeAll()
                    self.saveCards()
                }
                
                self.cards.append(StructOxfordData(word: word,
                                              definition: definition,
                                              example: example,
                                              lexicalCategory: lexicalCategory,
                                              phoneticSpelling: phoneticSpelling,
                                              audioFile: audioFile)!)
                self.saveCards()
                
                print("\(self.cards.count) - \(count)")
                if self.cards.count == count {
                    
                    //Load data before adding
                    if let savedBoxes = self.loadBoxes() {
                        self.boxes = savedBoxes
                    }
                    
                    self.cards.reverse()
                    
                    self.boxes.insert(Boxes(name: name, cards: self.cards)!, at: 0) //Insert at the beginning or array (to make it history - like)
                    self.saveBoxes()
                    
                    self.cards.removeAll()
                    self.saveCards()
                }
                
            } else {
                print(error ?? "No error (Should never happen)")
                print(NSString.init(data: data!, encoding: String.Encoding.utf8.rawValue) ?? "(Should never happen)")
            }
        }).resume()
    }
    
    private func saveBoxes() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(boxes, toFile: Boxes.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Boxes successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save boxes...", log: OSLog.default, type: .error)
        }
    }
    
    private func saveCards() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(cards, toFile: StructOxfordData.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Cards successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save cards...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadCards() -> [StructOxfordData]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: StructOxfordData.ArchiveURL.path) as? [StructOxfordData]
    }
    
    private func loadBoxes() -> [Boxes]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Boxes.ArchiveURL.path) as? [Boxes]
    }
}
