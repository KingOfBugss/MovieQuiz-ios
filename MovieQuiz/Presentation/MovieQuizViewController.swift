import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    private let presenter = MovieQuizPresenter()
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var correctAnswer = 0
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

        let alertPresenter = AlertPresenter(delegate: self)
        self.alertPresenter = alertPresenter
        
        staticService = StatisticServiceImplementation()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        hideLoadingIndicator()
        
        guard let question = question else { return }
        
        currentQuestion = question
        
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        answerGived(answer: true)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        answerGived(answer: false)
    }
    
    func showAlert(alert: UIAlertController?) {
        guard let alert else { return }
        
        self.present(alert, animated: true)
    }
    
    private func answerGived(answer: Bool) {
        guard let correntAnswer = currentQuestion else {return}
        showAnswerResult(isCorrect: correntAnswer.currentAnswer == answer)
    }
    
    private func showResult(quiz resultViewModel: QuizResultViewModel) {
        staticService?.store(correct: correctAnswer, total: presenter.questionsAmount)
        let prettyDate = staticService?.bestGame.date
//        let prettyDate = (staticService?.bestGame.date ?? Date()).dateTimeString
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
            self?.presenter.currentQuestionIndex = 0
            self?.correctAnswer = 0
            self?.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.showResualtAlert(model: alertModel)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswer += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        enableButtons(isEnable: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.enableButtons(isEnable: true)
            self.imageView.layer.borderWidth = 0
            self.showNextQuestionOrResults()
        }
    }
    
    
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        questionTextView.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            let text = "Ваш результат: \(correctAnswer)/10"
            let viewModel = QuizResultViewModel(
                        title: "Этот раунд окончен!",
                        text: text,
                        buttonText: "Сыграть ещё раз")
            
            showResult(quiz: viewModel)
        } else {
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
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
            self?.presenter.reseQuestionIndex()
            self?.correctAnswer = 0
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
