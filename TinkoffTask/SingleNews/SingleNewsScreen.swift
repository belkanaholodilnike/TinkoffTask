//
//  SingleNews.swift
//  TinkoffTask
//
//  Created by Sher Locked on 05.07.2018.
//  Copyright © 2018 Sher Locked. All rights reserved.
//

import UIKit

class SingleNewsScreen: UIViewController {
    
    var news: News?
    var networkService: NetworkServiceProtocol!
    var errorHandler: ErrorHandlerProtocol!
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptiontextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let singleNews = news else {
            return
        }
        
        guard let id = singleNews.id else {
            return
        }
        
        news = CoreDataSupport.fetchNews(with: id)
        configure()
    }
    
    func configure() {
        guard let singleNews = news, let id = singleNews.id  else {
            return
        }
        if let attributedHeader = singleNews.headerText?.html2Attributed {
            let mutableAttributedHeader = NSMutableAttributedString(attributedString: attributedHeader)
            mutableAttributedHeader.addAttributes([.font: UIFont.systemFont(ofSize: 17)],
                                                  range: mutableAttributedHeader.mutableString.range(of: mutableAttributedHeader.string))
            headerLabel.attributedText = mutableAttributedHeader
        } else {
            headerLabel.attributedText = nil
        }
        
        descriptiontextView.attributedText = singleNews.descriptionText?.html2Attributed
    
        networkService.getDetailNews(newsId: id) { (description, error) in
            if let error = error {
                self.errorHandler.handleError(error)
                return
            }
            singleNews.descriptionText = description
            DispatchQueue.main.async {
                self.descriptiontextView.attributedText = singleNews.descriptionText?.html2Attributed
                CoreDataSupport.update(news: singleNews, shouldUpdateCounter: false, shouldUpdateDescription: true)
            }
        }
        
    }

  

}
