//
//  ContentVC.swift
//  EnglishTest
//
//  Created by QUANG on 2/23/17.
//  Copyright © 2017 QUANG INDUSTRIES. All rights reserved.
//

import UIKit
import AVFoundation

class ContentVC: UIViewController {
    
    //MARK: Properties
    var pageIndex: Int!
    //var imageIndex: UIImage!
    var wordIndex: String!
    var definitionIndex: String!
    var exampleIndex: String!
    var categoryIndex: String!
    var spellingIndex: String!
    var audioFileIndex: String!
    
    //MARK: Outlets
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var lblWord: UILabel!
    @IBOutlet weak var tvDescription: UITextView!
    @IBOutlet weak var lblExample: UILabel!
    @IBOutlet weak var lblSpelling: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    
    //MARK: Actions
    @IBAction func btnListen(_ sender: UIButton) {
        if let url = URL(string: audioFileIndex) {
            downloadFileFromURL(url: url)
        }
    }
    
    //MARK: Defaults
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.image.image = imageIndex
        self.lblWord.text = beautyText(for: wordIndex!)
        self.tvDescription.text = beautyText(for: definitionIndex!)
        self.lblExample.text = beautyText(for: exampleIndex!)
        self.lblSpelling.text = beautyText(for: "\(spellingIndex!)")
        self.lblCategory.text = beautyText(for: "\(categoryIndex!)") 
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Private Methods
    func beautyText(for text: String) -> String {
        var result = ""
        text.uppercased().enumerateSubstrings(in: text.startIndex..<text.endIndex, options: .bySentences) { (_, range, _, _) in
            var substring = text[range] // retrieve substring from original string
            
            let first = substring.remove(at: substring.startIndex)
            result += String(first).uppercased() + substring
        }
        return result
    }
    
    private func downloadFileFromURL(url: URL) {
        var downloadTask = URLSessionDownloadTask()
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { (URL, response, error) -> Void in
            if error == nil {
                self.play(url: URL!)
            }
        })
        downloadTask.resume()
    }
    
    var player = AVAudioPlayer()
    func play(url: URL) {
        print("playing \(url)")
        
        do {
            self.player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
        } catch let error as NSError {
            //self.player = nil
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
