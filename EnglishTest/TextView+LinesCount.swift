//
//  TextView+LinesCount.swift
//  EnglishTest
//
//  Created by QUANG on 2/25/17.
//  Copyright © 2017 QUANG INDUSTRIES. All rights reserved.
//

import UIKit

extension UITextView {
    
    func numberOfLines() -> Int{
        if let fontUnwrapped = self.font{
            return Int(self.contentSize.height / fontUnwrapped.lineHeight)
        }
        return 0
    }
    
}
