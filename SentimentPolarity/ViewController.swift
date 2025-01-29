import UIKit

final class ViewController: UIViewController {
    private lazy var titleLabel: UILabel = self.makeTitleLabel()
    private lazy var textView: UITextView = self.makeTextView()
    private lazy var accessoryView = UIView()
    private lazy var resultLabel: UILabel = self.makeResultLabel()
    private lazy var clearButton: UIButton = self.makeClearButton()
    private lazy var addToBankButton: UIButton = self.makeAddToBankButton()
    private lazy var auraLabel: UILabel = self.makeAuraLabel()  // Added aura label
    private var auraBalance: Int = 0 {
        didSet {
            auraLabel.text = "Aura: \(auraBalance)"
        }
    }

    private let padding = CGFloat(16)
    private var textViewBottomConstraint: NSLayoutConstraint?

    private let classificationService = ClassificationService()

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "AiAura"
        view.backgroundColor = UIColor(named: "BackgroundColor")
        view.addSubview(titleLabel)
        view.addSubview(textView)
        view.addSubview(addToBankButton)
        view.addSubview(auraLabel)  // Add aura label to view

        accessoryView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 60)
        accessoryView.addSubview(resultLabel)
        accessoryView.addSubview(clearButton)
        textView.inputAccessoryView = accessoryView

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidShow(notification:)),
            name: .UIKeyboardDidShow,
            object: nil
        )

        setupConstraints()
        show(sentiment: .neutral)
    }

    // MARK: - Data

    private func show(sentiment: Sentiment) {
        accessoryView.backgroundColor = sentiment.color
        resultLabel.text = sentiment.emoji
    }

    // MARK: - Actions

    @objc private func keyboardDidShow(notification: NSNotification) {
        let frameObject = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject
        if let keyboardRect = frameObject.cgRectValue {
            textViewBottomConstraint?.constant = -keyboardRect.size.height - padding
            view.layoutIfNeeded()
        }
    }

    @objc private func clearButtonDidTouchUpInside() {
        textView.text = ""
    }

    @objc private func addToBankButtonDidTouchUpInside() {
        if let sentiment = classificationService.predictSentiment(from: textView.text ?? "") {
            switch sentiment {
            case .positive:
                auraBalance += 1500
            case .negative:
                auraBalance -= 1000
            default:
                break
            }
        }
    }
}

// MARK: - Factory

private extension ViewController {
    func makeTitleLabel() -> UILabel {
        let label = UILabel()
        label.text = "AiAura"
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textAlignment = .center
        label.textColor = .black  // Text color black
        return label
    }

    func makeTextView() -> UITextView {
        let textView = UITextView()
        textView.layer.cornerRadius = 8
        textView.backgroundColor = .white
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = .black  // Text color black inside the text box
        textView.autocorrectionType = .no
        textView.delegate = self
        return textView
    }

    func makeResultLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }

    func makeClearButton() -> UIButton {
        let button = UIButton()
        button.setTitle("Clear", for: .normal)
        button.addTarget(self, action: #selector(clearButtonDidTouchUpInside), for: .touchUpInside)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .highlighted)
        return button
    }

    func makeAddToBankButton() -> UIButton {
        let button = UIButton()
        button.setTitle("Add to Bank", for: .normal)
        button.addTarget(self, action: #selector(addToBankButtonDidTouchUpInside), for: .touchUpInside)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor(named: "PositiveColor")
        button.layer.cornerRadius = 8
        return button
    }

    func makeAuraLabel() -> UILabel {  // Added aura label factory method
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        label.textAlignment = .center
        label.text = "Aura: 0"
        return label
    }
}

// MARK: - Layout

private extension ViewController {
    func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: padding).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding).isActive = true

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: padding).isActive = true
        textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding).isActive = true
        textView.heightAnchor.constraint(equalToConstant: 120).isActive = true

        addToBankButton.translatesAutoresizingMaskIntoConstraints = false
        addToBankButton.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: padding).isActive = true
        addToBankButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding).isActive = true
        addToBankButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding).isActive = true
        addToBankButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        auraLabel.translatesAutoresizingMaskIntoConstraints = false
        auraLabel.topAnchor.constraint(equalTo: addToBankButton.bottomAnchor, constant: padding).isActive = true
        auraLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding).isActive = true
        auraLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding).isActive = true
        auraLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true

        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.centerXAnchor.constraint(equalTo: accessoryView.centerXAnchor).isActive = true
        resultLabel.centerYAnchor.constraint(equalTo: accessoryView.centerYAnchor).isActive = true

        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.trailingAnchor.constraint(equalTo: accessoryView.trailingAnchor, constant: -padding).isActive = true
        clearButton.centerYAnchor.constraint(equalTo: accessoryView.centerYAnchor).isActive = true
    }
}

// MARK: - UITextViewDelegate

extension ViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text else {
            return
        }

        if let sentiment = classificationService.predictSentiment(from: text) {
            show(sentiment: sentiment)
        }
    }
}
