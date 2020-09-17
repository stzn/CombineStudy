//
//  ViewController.swift
//  UserRegistration
//
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Views

    private let inValidCheckImage = UIImage(systemName: "xmark.circle.fill")!
        .withTintColor(.red, renderingMode: .alwaysOriginal)
    private let validCheckImage = UIImage(systemName: "checkmark.circle.fill")!
        .withTintColor(.green, renderingMode: .alwaysOriginal)

    private lazy var registerIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        registerLoadingView.addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: registerLoadingView.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: registerLoadingView.centerYAnchor)
        ])
        return indicator
    }()

    private lazy var registerLoadingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        return view
    }()

    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var idValidationIndicator: UIActivityIndicatorView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton! {
        didSet {
            registerButton.isEnabled = false
        }
    }
    @IBOutlet weak var idValidCheckImageView: UIImageView! {
        didSet {
            idValidCheckImageView.image = inValidCheckImage
        }
    }
    @IBOutlet weak var passwordValidCheckImageView: UIImageView! {
        didSet {
            passwordValidCheckImageView.image = inValidCheckImage
        }
    }
    @IBOutlet weak var passwordConfirmValidCheckImageView: UIImageView! {
        didSet {
            passwordConfirmValidCheckImageView.image = inValidCheckImage
        }
    }

    // MARK: - Private Variables

    private let api = DummyAPI()
    private var previousIdText: String = ""

    private var isIdValid = false {
        didSet {
            let image = isIdValid ? validCheckImage : inValidCheckImage
            idValidCheckImageView.image = image
            toggleRegisterButtonIsEnabled()
        }
    }

    private var isPasswordValid = false {
        didSet {
            let image = isPasswordValid ? validCheckImage : inValidCheckImage
            passwordValidCheckImageView.image = image
            toggleRegisterButtonIsEnabled()
        }
    }

    private var isPasswordCofirmValid = false {
        didSet {
            let image = isPasswordCofirmValid ? validCheckImage : inValidCheckImage
            passwordConfirmValidCheckImageView.image = image
            toggleRegisterButtonIsEnabled()
        }
    }

    // MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(idTextDidChange),
                                               name: UITextField.textDidChangeNotification,
                                               object: idTextField)
        NotificationCenter.default.addObserver(self, selector: #selector(passwordConfirmTextDidChange),
                                               name: UITextField.textDidChangeNotification,
                                               object: passwordConfirmTextField)
        NotificationCenter.default.addObserver(self, selector: #selector(passwordTextDidChange),
                                               name: UITextField.textDidChangeNotification,
                                               object: passwordTextField)
//        idTextField.addTarget(self, action: #selector(idTextDidChange),for: .editingChanged)
//        passwordTextField.addTarget(self, action: #selector(passwordTextDidChange),for: .editingChanged)
//        passwordConfirmTextField.addTarget(self, action: #selector(passwordConfirmTextDidChange),for: .editingChanged)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - User Actions

    @IBAction func registerButtonTapped(_ sender: UIButton) {
        startRegisterRequest()
        api.register { result in
            DispatchQueue.main.async { [weak self] in
                self?.showRegisterResult(result)
            }
        }
    }

    private func startRegisterRequest() {
        view.isUserInteractionEnabled = false
        view.addSubview(registerLoadingView)
        registerLoadingView.frame = view.bounds
        registerButton.isEnabled = false
        registerIndicator.startAnimating()
    }

    private func stopRegisterRequest() {
        registerButton.isEnabled = true
        registerIndicator.stopAnimating()
        registerLoadingView.removeFromSuperview()
        view.isUserInteractionEnabled = true
    }

    private func showRegisterResult(_ isSuccess: Bool) {
        let title: String
        let message: String
        if isSuccess {
            title = "成功"
            message = "登録が完了しました"
        } else {
            title = "失敗"
            message = "もう一度お試しください"
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(
            .init(title: "OK", style: .default) { [weak self] _ in
                self?.stopRegisterRequest()
        })
        present(alert, animated: true)
    }

    @objc
    private func idTextDidChange(_ sender: UITextField) {
        // registerButtonの押下不可
        if registerButton.isEnabled {
            registerButton.isEnabled = false
        }

        // インディケータ表示
        idValidationIndicator.startAnimating()

        // 入力を1秒待つ
        debounce(interval: 1000, queue: .main) { [weak self] in
            guard let self = self else {
                return
            }

            // 未入力の場合はリクエストを送らない
            guard let id = self.idTextField.text else {
                return
            }

            // 重複を避ける
            if self.previousIdText == id {
                return
            }
            self.previousIdText = id

            // APIリクエストを送る
            self.api.validateId(id) { result in
                // Main Threadで処理を続ける
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {
                        return
                    }
                    // APIリクエストの結果を通知
                    self.isIdValid = result
                    // インディケータ非表示
                    self.idValidationIndicator.stopAnimating()
                    // registerButtonの制御
                    self.toggleRegisterButtonIsEnabled()
                }
            }
        }
    }

    private func toggleRegisterButtonIsEnabled() {
        registerButton.isEnabled = isIdValid && isPasswordValid && isPasswordCofirmValid
    }

    @objc
    private func passwordTextDidChange(_ sender: UITextField) {
        configurePasswordTextFields()
    }

    @objc
    private func passwordConfirmTextDidChange(_ sender: UITextField) {
        configurePasswordTextFields()
    }

    private func configurePasswordTextFields() {
        isPasswordValid = (passwordTextField.text?.count ?? 0) > 5
        let isSamePassword = passwordTextField.text == passwordConfirmTextField.text
        isPasswordCofirmValid = isSamePassword && isPasswordValid
    }

}

// MARK: - Helpers

private func debounce(interval: Int, queue: DispatchQueue,
                      action: @escaping (() -> Void)) {
    var lastFireTime = DispatchTime.now()
    let dispatchDelay = DispatchTimeInterval.milliseconds(interval)

    lastFireTime = DispatchTime.now()
    let dispatchTime: DispatchTime = DispatchTime.now() + dispatchDelay

    queue.asyncAfter(deadline: dispatchTime) {
        let when: DispatchTime = lastFireTime + dispatchDelay
        let now = DispatchTime.now()
        if now.rawValue >= when.rawValue {
            action()
        }
    }
}

// MARK: - API

struct DummyAPI {
    func validateId(_ text: String,
                    completion: @escaping (Bool) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            completion(text.count > 5)
        }
    }

    func register(completion: @escaping (Bool) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            completion(Int.random(in: 0...1000).isMultiple(of: 2))
        }
    }
}
