//
//  NetworkClient.swift
//  OMDB
//
//  Created by LasslopS on 17.11.20.
//

import Foundation

class NetworkClient {
    
    private let kBaseUrl = "http://www.omdbapi.com/"
    private let kApiKey = "489182a9"
    private let cache = NSCache<NSString, NSData>()
    
    static let shared : NetworkClient = {
        let instance = NetworkClient()
        return instance
    }()
    
    func search(for name: String, page: Int, handler: @escaping(Search?, Error?) -> Void){

        let queryParams = "?s=\(name)&apikey=\(kApiKey)&page=\(String(page))"
        let queryString = queryParams.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = kBaseUrl.appending(queryString!)
        let task = URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
            guard let data = data, error == nil else {
                print("something went wrong here")
                return
            }
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(Search.self, from: data)
                print(result)
                handler(result, nil)
            } catch let error {
                handler(nil, error)
                print(error)
            }
        }
        task.resume()
    }
    
    func getMovie(with id: String, handler: @escaping(Movie?, Error?) -> Void){

        let url = kBaseUrl.appending("?i=\(id)&apikey=\(kApiKey)")
        let task = URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
            guard let data = data, error == nil else {
                print("something went wrong here")
                return
            }
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(Movie.self, from: data)
                handler(result, nil)
            } catch let error {
                handler(nil, error)
                print(error)
            }
        }
        task.resume()
    }
    
    func getImage(url: String, handler: @escaping(Data?, Error?) -> Void){
        
        if url == "N/A" { return }
        let cacheID = NSString(string: url)
        if let cachedData = cache.object(forKey: cacheID) {
            handler((cachedData as Data), nil)
        } else {
            if let url = URL(string: url) {
                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if let _data = data {
                        self.cache.setObject(_data as NSData, forKey: cacheID)
                        handler(_data, nil)
                    }else{
                        handler(nil, error)
                    }
                }
                task.resume()
            }
        }
    }
    
}
