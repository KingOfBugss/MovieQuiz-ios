//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Ilya Shirokov on 31.01.2024.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    let questionsAmount: Int = 10
    var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
    private let statisticService: StatisticServiceProtocol!
    private weak var viewController: MovieQuizViewController?
    private var questionFactory: QuestionFactoryProtocol?
    var correctAnswer = 0
    
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()

    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        questionFactory?.requestNextQuestion()
        
        currentQuestionIndex = 0
        correctAnswer = 0
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswer += 1
        }
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }

    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        
        let givenAnswer = isYes
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.currentAnswer)
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
        
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            let text = "Ваш результат: \(correctAnswer)/10"
            let viewModel = QuizResultViewModel(
                        title: "Этот раунд окончен!",
                        text: text,
                        buttonText: "Сыграть ещё раз")
            
            viewController?.showResult(quiz: viewModel)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func showResult(quiz resultViewModel: QuizResultViewModel) -> String {
        statisticService.store(correct: correctAnswer, total: questionsAmount)
        
        let prettyDate = statisticService?.bestGame.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let prettyDateFormat = dateFormatter.string(from: prettyDate!)
        let message = """
        \(resultViewModel.text)
        Колличество сыгранных квизов: \(statisticService?.gameCount ?? 0)
        Рекорд: \(statisticService?.bestGame.correct ?? 0) / \(statisticService?.bestGame.total ?? 0) (\(prettyDateFormat))
        Средняя точность: \((statisticService?.totalAccuracy ?? 0) * 100)%
        """

        return message
    }
}
