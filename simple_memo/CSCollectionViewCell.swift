//
//  CSCollectionViewCell.swift
//  simple_memo
//
//  Created by 황규일 on 2022/01/24.
//

import UIKit

class CSCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var todo: UILabel!
    @IBOutlet weak var date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
