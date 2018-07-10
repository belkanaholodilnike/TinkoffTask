//
//  NetworkServiceProtocol.swift
//  TinkoffTask
//
//  Created by Sher Locked on 04.07.2018.
//  Copyright © 2018 Sher Locked. All rights reserved.
//

import Foundation

protocol NetworkServiceProtocol {
    func getNewsList(count: Int, offset: Int, completion: @escaping ([News], TTError?) -> Void)
    func getDetailNews(newsId: String, completion: @escaping (String?, TTError?) -> Void)
}
