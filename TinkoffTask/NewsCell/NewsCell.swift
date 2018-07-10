//
//  NewsCell.swift
//  TinkoffTask
//
//  Created by Sher Locked on 04.07.2018.
//  Copyright © 2018 Sher Locked. All rights reserved.
//

import UIKit

class NewsCell: UITableViewCell {
    

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    
    func configure(with news: News) {
        cellView.backgroundColor = UIColor.white
        cellView.layer.cornerRadius = 9
        if let attributedHeader = news.headerText?.html2Attributed {
            let mutableAttributedHeader = NSMutableAttributedString(attributedString: attributedHeader)
            mutableAttributedHeader.addAttributes([.font: UIFont.systemFont(ofSize: 17)],
                                                  range: mutableAttributedHeader.mutableString.range(of: mutableAttributedHeader.string))
             headerLabel.attributedText = mutableAttributedHeader
        } else {
             headerLabel.attributedText = nil
        }
        
        countLabel.text = "\(news.counter)"
        guard let date = news.date else {
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy HH:mm"
        dateLabel.text = dateFormatter.string(from: date)
    }
    
}
