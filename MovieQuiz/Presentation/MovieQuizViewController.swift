import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    private let presenter = MovieQuizPresenter()
    private var questionFactory: QuestionFactoryProtocol?
//    private var currentQuestion: QuizQuestion?
//    private var correctAnswer = 0
    private var alertPresenter: AlertPresenterProtocol?
    private var staticService: StatisticServiceProtocol?
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var questionTextView: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.delegate = self
        questionFactory?.requestNextQuestion()
        questionFactory?.loadData()
        showLoadingIndicator()
        presenter.viewController = self

        let alertPresenter = AlertPresenter(delegate: self)
        self.alertPresenter = alertPresenter
        
        staticService = StatisticServiceImplementation()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        hideLoadingIndicator()
        
        presenter.didReceiveNextQuestion(question: question)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    func showAlert(alert: UIAlertController?) {
        guard let alert else { return }
        
        self.present(alert, animated: true)
    }
    
    func showResult(quiz resultViewModel: QuizResultViewModel) {
        if let staticService = staticService {
            staticService.store(correct: presenter.correctAnswer, total: presenter.questionsAmount)
        }
        
        let prettyDate = staticService?.bestGame.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let prettyDateFormat = dateFormatter.string(from: prettyDate!)
        let message = """
        \(resultViewModel.text)
        Колличество сыгранных квизов: \(staticService?.gameCount ?? 0)
        Рекорд: \(staticService?.bestGame.correct ?? 0) / \(staticService?.bestGame.total ?? 0) (\(prettyDateFormat))
        Средняя точность: \((staticService?.totalAccuracy ?? 0) * 100)%
        """
        
        let alertModel = AlertModel(title: resultViewModel.title, message: message, buttonText: resultViewModel.buttonText) { [weak self] in
            self?.presenter.restartGame()
            self?.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.showResualtAlert(model: alertModel)
    }
    
    func showAnswerResult(isCorrect: Bool) {
        presenter.didAnswer(isCorrectAnswer: isCorrect)
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        enableButtons(isEnable: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.enableButtons(isEnable: true)
            self.imageView.layer.borderWidth = 0
            self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionOrResults()
        }
    }
    
    
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        questionTextView.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func enableButtons(isEnable: Bool) {
        yesButton.isEnabled = isEnable
        noButton.isEnabled = isEnable
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.activityIndicator.isHidden = true
        }
    }
    
    private func alertNetworkError(message: String) {
        hideLoadingIndicator()
        let errorAlertModel = AlertModel(title: "Ошибка!",
                                        message: message,
                                        buttonText: "Попробовать еще раз",
                                        completion: { [weak self] in
            self?.presenter.restartGame()
            self?.questionFactory?.requestNextQuestion()
        })

        alertPresenter?.showResualtAlert(model: errorAlertModel)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = false
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        alertNetworkError(message: error.localizedDescription)
    }
}
