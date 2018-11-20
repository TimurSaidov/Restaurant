//
//  Model.swift
//  Restaurant
//
//  Created by Timur Saidov on 18/11/2018.
//  Copyright © 2018 Timur Saidov. All rights reserved.
//

import Foundation
import UIKit

var isTableViewShown: Bool = false

var menu: [Dish] {
    let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/data.json"
    let urlPath = URL(fileURLWithPath: path)
    
    // Получение бинарных данных типа Data из файла по пути urlPath, где хранится json-объект типа Data.
    let dataFromURLPath = try? Data(contentsOf: urlPath)
    guard let data = dataFromURLPath else { return [] }
    
    let jsonDecoder = JSONDecoder()
    let menuDictionary: Menu?
    
    do {
        menuDictionary = try jsonDecoder.decode(Menu.self, from: data)
        
        guard let menuDictionary = menuDictionary else { return [] }
        let returnArray = menuDictionary.items
        
        print("Загруженные из файла и распарсенные данные: \(menuDictionary as Any)")
        
        return returnArray
    } catch {
        print("Не удалось распарсить данные. Неверные данные: \(error.localizedDescription)")
    }
    
    return []
}

var images: [String: UIImage] {
    guard let dictionaryOfDataImages = UserDefaults.standard.object(forKey: "ImagesOfDishes") as? [String: Data] else { return [:] }
    
    var returnDictionary: Dictionary<String, UIImage> = [:]
    
    for item in dictionaryOfDataImages {
        if let image = UIImage(data: item.value) {
            returnDictionary["\(item.key)"] = image
        }
    }
    
    print("Загруженный из UserDefaults и распарсенный словарь картинок: \(returnDictionary)")
    
    return returnDictionary
}

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
    
//    var delegate: // Для отображения Alert'ов.
    
    func loadData(completionHandler: (() -> Void)?) {
        let urlString = "http://api.armenu.net:8090/menu"

        guard let url = URL(string: urlString) else {
//            delegate // Неверный URL-адрес
            
            print("Неверный URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                completionHandler?()
                
//                delegate // Нет интернета
                
                print("Нет соединения с Интернетом")
                return
            }
            
            if let dataString = String(data: data, encoding: String.Encoding.utf8) {
                print("Пришедшие данные типа Data, конвертируемые в String: \(dataString)")
            }
            
            let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/data.json"
            let urlForSave = URL(fileURLWithPath: path)
            print("URL файла data.json - \(urlForSave)")
            
            do {
                try data.write(to: urlForSave) // Запись содержимого буфера данных в файл по пути urlForSave.
            } catch {
                print("Ошибка при записи данных в файл: \(error.localizedDescription)")
            }
            
            self.getImage()
            
            completionHandler?()
        }
        task.resume()
    }
    
    func getImage() {
        print("Поток, где загружаются данные (функция loadData): \(Thread.current)")
        
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/data.json"
        let urlPath = URL(fileURLWithPath: path)
        
        // Получение бинарных данных типа Data из файла по пути urlPath, где хранится json-объект типа Data.
        let dataFromURLPath = try? Data(contentsOf: urlPath) // Аналогична URLSession, отличие лишь в том, что Data(contentsOf:) не отправляется на фоновый поток, т.е. остается на вызывающем.
        guard let data = dataFromURLPath else { return }
        
        let jsonDecoder = JSONDecoder()
        let menuDictionary: Menu?
        
        do {
            menuDictionary = try jsonDecoder.decode(Menu.self, from: data)
            
            guard let menuDictionary = menuDictionary else { return }
            let loadArray = menuDictionary.items
            var dictionaryOfDataImage: [String: Data] = [:]
            
            for dish in loadArray {
                guard let url = URL(string: dish.imageUrl) else {
//                    delegate
                    
                    print("Неверный URL")
                    return
                }
                
                do {
                    let data = try Data(contentsOf: url.withHost(host: "api.armenu.net")!)
                    print("Поток, где загружаются картинки: \(Thread.current)")
                    dictionaryOfDataImage["\(dish.name)"] = data
                } catch {
                    print("Не удалось получить данные: \(error.localizedDescription)")
                }
            }
            
            print("Распарсенные картинки в словаре картинок: \(dictionaryOfDataImage.count)")
            
            UserDefaults.standard.set(dictionaryOfDataImage, forKey: "ImagesOfDishes")
            UserDefaults.standard.synchronize()
        } catch {
            print("Не удалось распарсить данные. Неверные данные: \(error.localizedDescription)")
        }
    }
}

extension URL {
    func withQueries(_ query: [String: String]) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.queryItems = query.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        return components?.url
    }
    
    func withHTTPS() -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.scheme = "https"
        return components?.url
    }
    
    func withHost(host: String) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.host = host
        return components?.url
    }
}
