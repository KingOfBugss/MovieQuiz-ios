//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Ilya Shirokov on 01.02.2024.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showResult(quiz result: QuizResultViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
    func enableButtons(isEnable: Bool)
}
