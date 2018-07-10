//
//  NewsListScreen.swift
//  TinkoffTask
//
//  Created by Sher Locked on 04.07.2018.
//  Copyright © 2018 Sher Locked. All rights reserved.
//

import UIKit
import CoreData

class NewsListScreen: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var newsArray: [News] = []
    
    var pagesLoaded = 0
    let pageSize = 20
    var isReloading = true
    
    var startLoadingIndex: Int {
        return pagesLoaded * pageSize
    }
    
    var networkService: NetworkServiceProtocol!
    var errorHandler: ErrorHandlerProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkChecking()
        configure()
        setupDataFromStorage()
        reloadTable()
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadTable), for: .valueChanged)
        return refreshControl
    }()
    
    func configure() {
        view.backgroundColor = UIColor.lightGray
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        let nib = UINib(nibName: "NewsCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "NewsCell")
        tableView.separatorStyle = .none
        tableView.addSubview(refreshControl)
    }
    
    func networkChecking() {
        if Reachability.isConnectedToNetwork() == true {
            print("Internet connection OK")
        } else {
            print("Internet connection FAILED")
            let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func reloadTable() {
        isReloading = true
        pagesLoaded = 0
        loadMoreNews(start: startLoadingIndex, limit: pageSize) {
            self.pagesLoaded += 1
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            self.isReloading = false
        }
    }
    
    func setupDataFromStorage() {
        newsArray = CoreDataSupport.fetchAllNews()
        tableView.reloadData()
    }
    
    func loadMoreNews(start: Int, limit: Int, completion: @escaping () -> Void) {
        networkService.getNewsList(count: limit, offset: start) { (news, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorHandler.handleError(error)
                    return
                }

                CoreDataSupport.save(news: news, shouldUpdateCounter: false, shouldUpdateDescription: false)
                let updatedNews = CoreDataSupport.fetchNews(with: news.compactMap{ $0.id })

                if self.isReloading {
                    self.newsArray = updatedNews
                } else {
                    self.newsArray.append(contentsOf: updatedNews)
                }
                completion()
            }
        }
    }


}

extension NewsListScreen: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == startLoadingIndex - 1 {
            loadMoreNews(start: startLoadingIndex, limit: pageSize) {
                self.pagesLoaded += 1
                tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let news = newsArray[indexPath.row]
        news.counter += 1
        let cell = tableView.cellForRow(at: indexPath) as? NewsCell
        cell?.configure(with: news)
        CoreDataSupport.update(news: news, shouldUpdateCounter: true, shouldUpdateDescription: false)
        let storyboard = UIStoryboard(name: "SingleNewsScreen", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SingleNewsScreen") as! SingleNewsScreen
        vc.news = news
        vc.networkService = NetworkService()
        vc.errorHandler = ErrorHandler(vc: vc)
        navigationController?.pushViewController(vc, animated: true)
    }

    
}

extension NewsListScreen: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell") as! NewsCell
        cell.configure(with: newsArray[indexPath.row])
        return cell
    }
}
