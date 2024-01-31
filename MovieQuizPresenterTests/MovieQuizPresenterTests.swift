//
//  MovieQuizPresenterTests.swift
//  MovieQuizPresenterTests
//
//  Created by Ilya Shirokov on 01.02.2024.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func enableButtons(isEnable: Bool) {

    }
    
    func showResult(quiz result: MovieQuiz.QuizResultViewModel) {

    }
    
    func show(quiz step: QuizStepViewModel) {
    
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
    
    }
    
    func showNetworkError(message: String) {
    
    }
    
    func showLoadingIndicator() {
    
    }
    
    func hideLoadingIndicator() {
    
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testControllerConvwrtModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", currentAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}

