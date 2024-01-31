import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate {
    
    private var presenter: MovieQuizPresenter!
//    private var questionFactory: QuestionFactoryProtocol?

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
//        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
//        questionFactory?.delegate = self
//        questionFactory?.requestNextQuestion()
//        questionFactory?.loadData()
        presenter = MovieQuizPresenter(viewController: self)
        showLoadingIndicator()
        
        let alertPresenter = AlertPresenter(delegate: self)
        self.alertPresenter = alertPresenter
        
        staticService = StatisticServiceImplementation()
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
    
    func showResult(quiz result: QuizResultViewModel) {
        let message = presenter.showResult(quiz: result)
        
        let alert = UIAlertController(
            title: result.title,
            message: message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.presenter.restartGame()
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
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
            self.presenter.showNextQuestionOrResults()
        }
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        questionTextView.text = step.question
        counterLabel.text = step.questionNumber
    }
    
     func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.activityIndicator.isHidden = true
        }
    }
    
    func showNetworkError(message: String) {
        alertNetworkError(message: message)
    }
    
    private func enableButtons(isEnable: Bool) {
        yesButton.isEnabled = isEnable
        noButton.isEnabled = isEnable
    }

    
    private func alertNetworkError(message: String) {
        hideLoadingIndicator()
        
        let errorAlertModel = AlertModel(title: "Ошибка!",
                                        message: message,
                                        buttonText: "Попробовать еще раз",
                                        completion: { [weak self] in
            self?.presenter.restartGame()
        })

        alertPresenter?.showResualtAlert(model: errorAlertModel)
    }
}
