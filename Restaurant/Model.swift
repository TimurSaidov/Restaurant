//
//  Model.swift
//  Restaurant
//
//  Created by Timur Saidov on 18/11/2018.
//  Copyright © 2018 Timur Saidov. All rights reserved.
//

import Foundation

var menu: [Dish] = []

struct Menu: Decodable {
    var items: [Dish]
}

struct Dish: Decodable {
    var description: String
    var name: String
    var imageUrl: String
    var id: Int
    var price: Int
    var category: String
    
    enum CodingKeys: String, CodingKey {
        case description
        case name
        case imageUrl = "image_url"
        case id
        case price
        case category
    }
    
    init(from decoder: Decoder) throws {
        let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        self.description = try valueContainer.decode(String.self, forKey: CodingKeys.description)
        self.name = try valueContainer.decode(String.self, forKey: CodingKeys.name)
        self.imageUrl = try valueContainer.decode(String.self, forKey: CodingKeys.imageUrl)
        self.id = try valueContainer.decode(Int.self, forKey: CodingKeys.id)
        self.price = try valueContainer.decode(Int.self, forKey: CodingKeys.price)
        self.category = try valueContainer.decode(String.self, forKey: CodingKeys.category)
    }
}

class Model {
    static let shared = Model()
    
    func loadData() {
        let urlString = "http://api.armenu.net:8090/menu"

        guard let url = URL(string: urlString) else {
            print("Неверный URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print("Неверные данные, пришедшие с сервера")
                return
            }
            
            if let dataString = String(data: data, encoding: String.Encoding.utf8) {
                print("Пришедшие данные типа Data, конвертируемые в String: \(dataString)")
            }
            
            let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/data.json"
            let urlForSave = URL(fileURLWithPath: path)
            print(urlForSave)
            
            do {
                try data.write(to: urlForSave) // Запись содержимого буфера данных в файл по пути urlForSave.
                
                self.parseData()
            } catch {
                print("Ошибка при записи данных в файл: \(error.localizedDescription)")
                
                self.parseData()
            }
        }
        task.resume()
    }
    
    func parseData() {
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/data.json"
        let urlPath = URL(fileURLWithPath: path)
        
        // Получение бинарных данных типа Data из файла по пути urlPath, где хранится json-объект типа json.
        let dataFromURLPath = try? Data(contentsOf: urlPath)
        guard let data = dataFromURLPath else { return }
        
        let jsonDecoder = JSONDecoder()
        let menuDictionary: Menu?
        
        do {
            menuDictionary = try jsonDecoder.decode(Menu.self, from: data)
            
            guard let menuDictionary = menuDictionary else { return }
            menu = menuDictionary.items
            
            print("Распарсенные данные: \(menuDictionary as Any)")
            print("Меню: \(menu); Блюд в меню - \(menu.count)")
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension URL {
    func withQueries(_ query: [String: String]) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        print("Components: \(components! as Any)")
        print("Components.queryItems: \(components!.queryItems as Any)")
        components?.queryItems = query.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        print("NEW Components.queryItems: \(components!.queryItems! as Any)")
        print("NEW Components: \(components! as Any)")
        print("NEW Components.url: \(components!.url! as Any)")
        return components?.url
    }
    
    func withHTTPS() -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        print("Components: \(components! as Any)")
        print("Components.scheme: \(components!.scheme! as Any)")
        components?.scheme = "https"
        print("NEW Components.scheme: \(components!.scheme! as Any)")
        print("NEW Components: \(components! as Any)")
        print("NEW Components.url: \(components!.url! as Any)")
        return components?.url
    }
    
    func withHost(host: String) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        print("Components: \(components! as Any)")
        print("Components.host: \(components!.host! as Any)")
        components?.host = host
        print("NEW Components.host: \(components!.host! as Any)")
        print("NEW Components: \(components! as Any)")
        print("NEW Components.url: \(components!.url! as Any)")
        return components?.url
    }
}
