//
//  HoldVC.swift
//  EnglishTest
//
//  Created by QUANG on 2/23/17.
//  Copyright © 2017 QUANG INDUSTRIES. All rights reserved.
//

import UIKit

class HoldVC: UIViewController, UIPageViewControllerDataSource {
    
    //MARK: Properties
    var pageViewController: UIPageViewController!
    //var pageImages: NSArray!
    var pageWords: [String]!
    var pageDefinitions: [String]!
    var pageExamples: [String]!
    var pageCategories: [String]!
    var pageSpellings: [String]!
    var pageAudioFiles: [String]!
    
    var box: Boxes?
    
    //var images: [UIImage]?
    var words: [String] = []
    var definitions: [String] = []
    var examples: [String] = []
    var categories: [String] = []
    var spellings: [String] = []
    var audioFiles: [String] = []

    //MARK: Defaults
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up views if editing an existing Task.
        if let box = box {
            getContent()
            
            navigationController?.title = box.name
            
            //self.pageImages = NSArray(array: images!)
            self.pageWords = words
            self.pageDefinitions = definitions
            self.pageExamples = examples
            self.pageCategories = categories
            self.pageSpellings = spellings
            self.pageAudioFiles = audioFiles
            
            self.pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "LearnPVC") as! UIPageViewController
            
            self.pageViewController.dataSource = self
            
            let startVC = self.viewController(at: 0) as ContentVC
            let viewControllers = NSArray(object: startVC)
            self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: .forward, animated: true, completion: nil)
            self.pageViewController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            self.addChildViewController(self.pageViewController)
            self.view.addSubview(self.pageViewController.view)
            self.pageViewController.didMove(toParentViewController: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Actions
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The HoldVC is not inside a navigation controller.")
        }
    }
    
    
    //MARK: Private Func
    func getContent() {
        if let box = box {
            for card in box.cards {
                //images?.append(#imageLiteral(resourceName: "Author Filled"))
                words.append(card.word)
                print(card.word)
                definitions.append(card.definition)
                print(card.definition)
                examples.append(card.example)
                print(card.example)
                categories.append(card.lexicalCategory)
                print(card.lexicalCategory)
                spellings.append(card.phoneticSpelling)
                print(card.phoneticSpelling)
                audioFiles.append(card.audioFile)
                print(card.audioFile)
                
                //print(words.count ?? 99)
            }
        }
    }
    
    func viewController(at index: Int) -> ContentVC {
        if self.pageWords.count == 0 || index >= self.pageWords.count {
            return ContentVC()
        }
        
        let VC: ContentVC = self.storyboard?.instantiateViewController(withIdentifier: "ContentVC") as! ContentVC
        
        //VC.imageIndex = self.pageImages[index] as! UIImage
        VC.wordIndex = beautyText(for: self.pageWords[index])
        VC.definitionIndex = beautyText(for: self.pageDefinitions[index])
        VC.exampleIndex = beautyText(for: self.pageExamples[index])
        VC.spellingIndex = beautyText(for: "\(self.pageSpellings[index])")
        VC.categoryIndex = beautyText(for: "\(self.pageCategories[index])")
        VC.audioFileIndex = beautyText(for: self.pageAudioFiles[index]) 
        VC.pageIndex = index
        
        return VC
    }
    
    func beautyText(for text: String) -> String {
        var result = ""
        text.uppercased().enumerateSubstrings(in: text.startIndex..<text.endIndex, options: .bySentences) { (_, range, _, _) in
            var substring = text[range] // retrieve substring from original string
            
            let first = substring.remove(at: substring.startIndex)
            result += String(first).uppercased() + substring
        }
        return result
    }

    //MARK: Page View Controller Data source
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let VC = viewController as! ContentVC
        var index = VC.pageIndex as Int
        
        if index == 0 || index == NSNotFound {
            return nil
        }
        
        index -= 1
        return self.viewController(at: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let VC = viewController as! ContentVC
        var index = VC.pageIndex as Int
        
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        
        if index == self.pageWords.count {
            return nil
        }
        
        return self.viewController(at: index)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.pageWords.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
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
