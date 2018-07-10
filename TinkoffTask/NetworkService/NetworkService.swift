//
//  NetworkService.swift
//  TinkoffTask
//
//  Created by Sher Locked on 04.07.2018.
//  Copyright © 2018 Sher Locked. All rights reserved.
//

import Foundation

class NetworkService: NetworkServiceProtocol {
    
    func getNewsList(count: Int, offset: Int, completion: @escaping ([News], TTError?) -> Void) {
        let urlString = "https://api.tinkoff.ru/v1/news"
        
        let params: [String: String] = ["first": String(offset),
                                        "last": String(offset + count)]
        
        guard let request = createRequest(urlString: urlString, params: params) else {
            let error = TTError(type: .requestCreationError)
            completion([], error)
            return
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                let tError = TTError(error: error)
                completion([], tError)
                return
            }
            
            guard let data = data else {
                let error = TTError(type: .jsonSerializationError)
                completion([], error)
                return
            }
            
            let responseObject = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
            guard let responseArray = (responseObject?["payload"] as? [[String: Any]]) else {
                let error = TTError(type: .jsonSerializationError)
                completion([], error)
                return
            }
            let news = responseArray.map({ dict -> News in
                let id = dict["id"] as? String
                let text = dict["text"] as? String
                let dateJSON = dict["publicationDate"] as? [String: Any]
                var date: Date?
                if let timeInterval = dateJSON?["milliseconds"] as? Int {
                    date = Date(timeIntervalSince1970: TimeInterval(timeInterval) / 1000)
                }
                return News(headerText: text, descriptionText: nil, id: id, date: date)
            })
            
            completion(news, nil)
        }
        
        task.resume()
    }
    
    func getDetailNews(newsId: String, completion: @escaping (String?, TTError?) -> Void) {
        
        let urlString = "https://api.tinkoff.ru/v1/news_content"
        
        let params: [String: String] = ["id": newsId]
        
        guard let request = createRequest(urlString: urlString, params: params) else {
            let error = TTError(type: .requestCreationError)
            completion(nil, error)
            return
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                let tError = TTError(error: error)
                completion(nil, tError)
                return
            }
            
            guard let data = data else {
                let error = TTError(type: .jsonSerializationError)
                completion(nil, error)
                return
            }
            
            let responseObject = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
            guard let responseArray = (responseObject?["payload"] as? [String: Any]) else {
                let error = TTError(type: .jsonSerializationError)
                completion(nil, error)
                return
            }
            let description = responseArray["content"] as? String
            completion (description, nil)
        }
        
        task.resume()
    }
    
    private func createRequest(urlString: String, params: [String: String]) -> URLRequest? {
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        
        components.queryItems = params.map({ (key, value) -> URLQueryItem in
            return URLQueryItem(name: key, value: value)
        })
        
        guard let urlWithParams = components.url else {
            return nil
        }
        
        let request = URLRequest(url: urlWithParams)
        return request
    }
    
 
}
