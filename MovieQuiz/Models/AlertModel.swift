//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Ilya Shirokov on 20.12.2023.
//

import Foundation

struct AlertModel {
    static func make(from quizResualtModel: QuizResultViewModel, with completion: @escaping () -> ()) -> AlertModel {
        AlertModel(title: quizResualtModel.title, message: quizResualtModel.text, buttonText: quizResualtModel.buttonText, completion: completion)
    }
    
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> ()
}
