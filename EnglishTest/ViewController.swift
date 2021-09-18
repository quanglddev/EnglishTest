//
//  ViewController.swift
//  EnglishTest
//
//  Created by QUANG on 2/22/17.
//  Copyright © 2017 QUANG INDUSTRIES. All rights reserved.
//

import UIKit
import os.log
import SCLAlertView
import JGProgressHUD
import ChameleonFramework

class ViewController: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {

    //MARK: Properties
    var boxes = [Boxes]()
    var cards = [StructOxfordData]()
    
    var timer = Timer()
    
    let defaults = UserDefaults.standard
    
    var stopTask = false
    
    struct defaultsKeys {
        static let lastText = "lastText"
        static let taskTerminated = "taskTerminated"
    }
    
    //MARK: Outlets
    @IBOutlet weak var wordsField: UITextView!
    @IBOutlet weak var btnCreateOutlet: UIButton!
    @IBOutlet weak var historyTableViewOutlet: UITableView!
    
    @IBOutlet weak var btnClearOutlet: UIBarButtonItem!
    @IBOutlet weak var btnSettingsOutlet: UIBarButtonItem!
    
    //MARK: Actions
    @IBAction func clearWordsField(_ sender: UIBarButtonItem) {
        wordsField.text = ""
    }
    
    @IBAction func btnCreateAction(_ sender: UIButton) {
        let appearance = SCLAlertView.SCLAppearance(showCloseButton: true)
        let alert = SCLAlertView(appearance: appearance)
        let txt = alert.addTextField("Box Intermediate Word")
        _ = alert.addButton("Create") {
            self.cards.removeAll()
            self.saveCards()
            
            self.title = "Home"
            
            var words = self.wordsField.text.replacingOccurrences(of: " ", with: "").components(separatedBy: "\n") // ["Hello", "World"]
            
            while words[words.endIndex - 1] == "" {
                words.remove(at: words.endIndex - 1)
            }
            
            self.create(box: txt.text!, words: words, count: words.count) //Every card is a word
            
            let HUD: JGProgressHUD = self.prototypeHUD()
            HUD.detailTextLabel.text = "0% Complete";
            HUD.textLabel.text = "Collecting...";
            HUD.show(in: self.navigationController?.view)
            HUD.layoutChangeAnimationDuration = 0.0
            
            self.incrementHUD(HUD: HUD, progress: 0)
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in
                self.incrementHUD(HUD: HUD, progress: self.updateProgressStatus(expectedCards: words.count))
            })
        }
        _ = alert.showEdit("Confirm", subTitle: "Enter this box name: ", closeButtonTitle: "Cancel")
    }
    
    //MARK: Defaults
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigationItem.leftBarButtonItem = editButtonItem
        
        wordsField.delegate = self //Without setting the delegate you won't be able to track UITextView events
        
        DispatchQueue.main.async {
            self.updateUI()
        }
        
        //Clear when debugging
        if let savedBoxes = loadBoxes() {
            boxes += savedBoxes
            print("Boxes: \(boxes.count)")
            print("Cards: \(boxes[0].cards.count)")
        }
        else{let words = ["Hello", "morning", "monkey", "dragon"]
            create(box: "Box 1", words: words, count: words.count)
            
        }
        
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appWillTerminate), name: Notification.Name.UIApplicationWillTerminate, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appWillEnterForeground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        
        
        if let history = defaults.string(forKey: defaultsKeys.lastText) {
            wordsField.text = history
        }
        
        
        DispatchQueue.main.async {
            self.view.backgroundColor = ContrastColorOf(.white, returnFlat: false)
            
            self.wordsField.backgroundColor = RandomFlatColor()
            self.wordsField.textColor = ContrastColorOf(self.wordsField.backgroundColor!, returnFlat: true)
            
            self.btnCreateOutlet.backgroundColor = RandomFlatColor()
            self.btnCreateOutlet.tintColor = ContrastColorOf(self.btnCreateOutlet.backgroundColor!, returnFlat: true)
            
            self.navigationController?.navigationBar.barTintColor = RandomFlatColor()
            self.btnSettingsOutlet.tintColor = ContrastColorOf((self.navigationController?.navigationBar.barTintColor)!, returnFlat: true)
            self.btnClearOutlet.tintColor = self.btnSettingsOutlet.tintColor
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: self.btnClearOutlet.tintColor!]
        }
        
        wordsField.textContainer.maximumNumberOfLines = 60
        wordsField.textContainer.lineBreakMode = .byWordWrapping
    }
    
    
    func appMovedToBackground() {
        print("App moved to background!")
        if !wordsField.text.isEmpty {
        defaults.set(wordsField.text, forKey: defaultsKeys.lastText)
        }
        defaults.set(true, forKey: defaultsKeys.taskTerminated)
        
        stopTask = true
    }
    
    func appWillEnterForeground() {
        stopTask = false
        
        self.defaults.set(false, forKey: defaultsKeys.taskTerminated)
    }
    
    func appWillTerminate() {
        print("App will be terminated soon!")
        if !wordsField.text.isEmpty {
        defaults.set(wordsField.text, forKey: defaultsKeys.lastText)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        wordsField.setContentOffset(CGPoint.zero, animated: true)
    }
    
    //MARK: UITextFieldDelegate
    
    private func setupKeyboard() {
        // Handle the text field’s user input through delegate callbacks.
        wordsField.delegate = self
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.title = "\(wordsField.numberOfLines()) Words"
        
        if !wordsField.text.isEmpty {
            defaults.set(wordsField.text, forKey: defaultsKeys.lastText)
        }
    }

    ///////////////////////////////////////////////////////////////
    
    //MARK: TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return boxes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.historyTableViewOutlet.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryCell
                
        cell.boxName.text = boxes[indexPath.row].name
        cell.placeholderView.backgroundColor = RandomFlatColor()
        cell.boxName.textColor = ContrastColorOf(cell.placeholderView.backgroundColor!, returnFlat: true)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "History"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            boxes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            saveBoxes()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func setEditing(_ editing: Bool, animated: Bool){
        super.setEditing(editing, animated: animated)
        historyTableViewOutlet.setEditing(editing, animated: true)
    }
    
    //MARK: Private Method
    private func updateProgressStatus(expectedCards: Int) -> Float {
        if let savedCards = self.loadCards() {
            self.cards += savedCards
            
            if let savedBoxes = loadBoxes() {
                boxes = savedBoxes
                print("Boxes: \(boxes.count)")
                print("Cards: \(boxes[0].cards.count)")
            }
            
            if boxes.count == historyTableViewOutlet.numberOfRows(inSection: 0) + 1 {
                print(historyTableViewOutlet.numberOfRows(inSection: 0))
                print(boxes.count)
                historyTableViewOutlet.reloadData()
                
                return 1.0 //Completed
            }
            
            if cards.count < expectedCards {
                let progress: Float = ((Float(cards.count) / Float(expectedCards)) * 100).rounded() / 100
                
                return progress
            }
            
            if cards.count == expectedCards {
                historyTableViewOutlet.reloadData()
                
                return 1.0 //Completed
            }
            
            return 0.0
        }
        else {
            return 0.0
        }
    }
    
    
    private func prototypeHUD() -> JGProgressHUD {
        let HUD: JGProgressHUD = JGProgressHUD.init(style: .extraLight)
        HUD.square = true
        HUD.interactionType = .blockAllTouches
        HUD.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
        HUD.hudView.layer.shadowColor = UIColor.black.cgColor
        HUD.hudView.layer.shadowOffset = CGSize.zero
        HUD.hudView.layer.shadowOpacity = 0.4
        HUD.hudView.layer.shadowRadius = 8.0
        HUD.indicatorView = JGProgressHUDRingIndicatorView.init()
        
        //HUD.delegate = self
        
        return HUD
    }
    
    
    private func incrementHUD(HUD: JGProgressHUD, progress: Float) {
        HUD.setProgress(progress, animated: true)
        HUD.detailTextLabel.text = "\(Int(progress * 100))% Complete"
        print(progress)
        if Int(progress * 100) >= 100 {
            HUD.textLabel.text = "Success!"
            HUD.detailTextLabel.text = nil
            
            HUD.layoutChangeAnimationDuration = 0.3
            HUD.indicatorView = JGProgressHUDSuccessIndicatorView.init()
            
            timer.invalidate()
            HUD.dismiss(afterDelay: 3)
        }
        
        if (stopTask) {
            HUD.textLabel.text = "Fail!"
            HUD.detailTextLabel.text = nil
            
            HUD.layoutChangeAnimationDuration = 0.3
            HUD.indicatorView = JGProgressHUDErrorIndicatorView.init()
            
            timer.invalidate()
            HUD.dismiss(afterDelay: 3)
            
            
        }
    }
    
    private func create(box name: String, words: [String], count: Int) {
        if !defaults.bool(forKey: defaultsKeys.taskTerminated) {
            for word in words {
                getData(box: name, word: word, count: count)
            }
        }
        else {
            cards.removeAll()
            saveCards()
        }
    }
    
    private func getData(box name: String, word: String, count: Int) {
        _ = OxfordGetData().getOxfordDataFor(box: name, for: word, count: count)
    }
    
    private func loadBoxes() -> [Boxes]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Boxes.ArchiveURL.path) as? [Boxes]
    }
    
    private func saveBoxes() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(boxes, toFile: Boxes.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Boxes successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save boxes...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadCards() -> [StructOxfordData]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: StructOxfordData.ArchiveURL.path) as? [StructOxfordData]
    }
    
    private func saveCards() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(cards, toFile: StructOxfordData.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Cards successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save cards...", log: OSLog.default, type: .error)
        }
    }
    
    private func updateUI() {
        //wordsField.backgroundColor = UIColor.init(red: 55/255.0, green: 139/255.0, blue: 128/255.0, alpha: 1.0)
        //Input View
        wordsField.layer.cornerRadius = 10.0
        wordsField.layer.shadowColor = UIColor.blue.withAlphaComponent(0.2).cgColor
        wordsField.layer.shadowOffset = CGSize(width: 0, height: 0)
        wordsField.layer.shadowOpacity = 0.8
        
        //Button
        btnCreateOutlet.layer.cornerRadius = 10.0
        btnCreateOutlet.layer.shadowColor = UIColor.blue.withAlphaComponent(0.2).cgColor
        btnCreateOutlet.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnCreateOutlet.layer.shadowOpacity = 0.8
        
        //Table View
        historyTableViewOutlet.layer.cornerRadius = 10.0
        historyTableViewOutlet.layer.shadowColor = UIColor.blue.withAlphaComponent(0.2).cgColor
        historyTableViewOutlet.layer.shadowOffset = CGSize(width: 0, height: 0)
        historyTableViewOutlet.layer.shadowOpacity = 0.8
    }
    
    
    //MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "ShowDetail":
            guard let holdLearningVC = segue.destination as? HoldVC else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedBoxCell = sender as? HistoryCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = historyTableViewOutlet.indexPath(for: selectedBoxCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedBox = boxes[indexPath.row]
            holdLearningVC.box = selectedBox
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
}

