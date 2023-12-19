//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Ilya Shirokov on 20.12.2023.
//

import UIKit

class AlertPresenter: AlertPresenterProtocol {
    private weak var parrentController: UIViewController?
    
    init(parrentController: UIViewController?) {
        self.parrentController = parrentController
    }
    
    func showAlert(with model: AlertModel) {
        let alertController = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        alertController.addAction(action)
        parrentController?.present(alertController, animated: true)
    }
}
