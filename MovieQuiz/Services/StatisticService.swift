//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Ilya Shirokov on 21.12.2023.
//

import Foundation

protocol StatisticService {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    
    func store(correct count:Int, total amount: Int)
}

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetter(another: GameRecord) -> Bool {
        correct > another.correct
    }
}

final class StatisticServiceImplementation: StatisticService {
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    private let convertData = Date().dateTimeString
    private let userDefault = UserDefaults.standard
    
    var totalAccuracy: Double {
        get {
            let corrects = userDefault.integer(forKey: Keys.correct.rawValue)
            let totals = userDefault.integer(forKey: Keys.total.rawValue)
            
            return Double(corrects) / Double(totals)
        }
    }
    
    var gamesCount: Int {
        get {
            return userDefault.integer(forKey: Keys.gamesCount.rawValue)
        }

        set {
            userDefault.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefault.data(forKey: Keys.bestGame.rawValue),
                let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Результать сохранить невозможно")
                return
            }
            userDefault.set(data, forKey: Keys.bestGame.rawValue)
        }
    }

    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        
//        var currentGame: GameRecord = GameRecord(correct: count, total: amount, date: Date())
//        if bestGame > currentGame {
//            
//        }  //Ошибка Binary operator '>' cannot be applied to two 'GameRecord' operands
        
// количество правильных ответов за всё время
        var corrects = userDefault.integer(forKey: Keys.correct.rawValue)
        corrects += count
        userDefault.set(corrects, forKey: Keys.correct.rawValue)
        
// сохраняем количество сыгранных вопросов за всё время
        var totals = userDefault.integer(forKey: Keys.total.rawValue)
        totals += amount
        userDefault.set(totals, forKey: Keys.total.rawValue)
        
        
    }
}
