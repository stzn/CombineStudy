//
//  ViewController.swift
//  UserRegistrationCombine
//
//

import Combine
import UIKit
import TimelaneCombine

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

    @Published private var idValidatioRequesting = false
    @Published private var registerRequesting = false
    @Published private var isIdValid = false
    @Published private var isPasswordValid = false
    @Published private var isPasswordCofirmValid = false
    private var isRegisterSucceeded = PassthroughSubject<Bool, Never>()

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        // ID欄への入力が変更された際に入力値が妥当かどうかで
        // チェックマークのイメージを変更している
        $isIdValid.sink { [self] isValid in
            let image = isValid ? validCheckImage : inValidCheckImage
            idValidCheckImageView.image = image
        }
        .store(in: &cancellables)

        // パスワード欄への入力が変更された際に入力値が妥当かどうかで
        // チェックマークのイメージを変更している
        $isPasswordValid.sink { [self] isValid in
            let image = isValid ? validCheckImage : inValidCheckImage
            passwordValidCheckImageView.image = image
        }.store(in: &cancellables)

        // パスワード確認欄への入力が変更された際に入力値が妥当かどうかで
        // チェックマークのイメージを変更している
        $isPasswordCofirmValid.sink { [self] isValid in
            let image = isValid ? validCheckImage : inValidCheckImage
            passwordConfirmValidCheckImageView.image = image
        }.store(in: &cancellables)

        // ID, パスワード, パスワード確認の変更に応じて
        // registerButtonの押下可、不可を変更している
        Publishers.CombineLatest4($isIdValid, $isPasswordValid,
                                  $isPasswordCofirmValid, $registerRequesting)
            .map { $0 && $1 && $2 && !$3 }
            .assign(to: \.isEnabled, on: registerButton)
            .store(in: &cancellables)

        let idTextDidChangePublisher = NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: idTextField)
            // String? → Stringに変換
            .map { ($0.object as! UITextField).text! }

        let passwordTextDidChangePublisher = NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: passwordTextField)
            // String? → Stringに変換
            .map { ($0.object as! UITextField).text! }

        let passwordConfirmTextDidChangePublisher = NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: passwordConfirmTextField)
            // String? → Stringに変換
            .map { ($0.object as! UITextField).text }

        if #available(iOS 14.0, *) {
            // ID欄の入力値を受け取り、APIリクエストを送り、結果をisIdValidに反映させている
            idTextDidChangePublisher
                .lane("idTextDidChange")
                .handleEvents(receiveOutput: { _ in self.idValidatioRequesting = true }) // インディケータ表示, registerButtonの押下不可
                .debounce(for: 1.0, scheduler: DispatchQueue.main) // 入力を1秒待つ
                .filter { !$0.isEmpty } // 未入力の場合はリクエストを送らない
                .removeDuplicates() // 重複を避ける
                .flatMap(api.validateId) // APIリクエストを送る
                .receive(on: DispatchQueue.main) // Main Threadで処理を続ける
                .handleEvents(receiveOutput: { _ in self.idValidatioRequesting = false }) // インディケータ非表示, registerButtonの制御
                .assign(to: &$isIdValid) // APIリクエストの結果を通知

            // パスワード欄の入力値を受け取り、結果をisPasswordValidに反映させている
            passwordTextDidChangePublisher
                .filter { !$0.isEmpty } // 未入力の場合はリクエストを送らない
                .map { $0.count > 5 } // パスワードのバリデーション
                .assign(to: &$isPasswordValid) // パスワードのバリデーション結果の通知

            // パスワード確認欄の入力値とパスワード欄の入力値を受け取り
            // 結果をisPasswordConfirmValidに反映させている
            passwordConfirmTextDidChangePublisher
                .combineLatest(passwordTextDidChangePublisher)
                .map { passwordText, confirmText in
                    passwordText == confirmText && self.isPasswordValid
                }
                .assign(to: &$isPasswordCofirmValid)

        } else {
            // ID欄の入力値を受け取り、APIリクエストを送り、結果をisIdValidに反映させている
            idTextDidChangePublisher
                .lane("idTextDidChange")
                .handleEvents(receiveOutput: { _ in self.idValidatioRequesting = true }) // インディケータ表示, registerButtonの押下不可
                .debounce(for: 1.0, scheduler: DispatchQueue.main) // 入力を1秒待つ
                .filter { !$0.isEmpty } // 未入力の場合はリクエストを送らない
                .removeDuplicates() // 重複を避ける
                .flatMap(api.validateId) // APIリクエストを送る
                .receive(on: DispatchQueue.main) // Main Threadで処理を続ける
                .handleEvents(receiveOutput: { _ in self.idValidatioRequesting = false }) // インディケータ非表示, registerButtonの制御
                .sink { result in self.isIdValid = result } // APIリクエストの結果を通知
                .store(in: &cancellables)

            // パスワード欄の入力値を受け取り、結果をisPasswordValidに反映させている
            passwordTextDidChangePublisher
                .filter { !$0.isEmpty } // 未入力の場合はリクエストを送らない
                .map { $0.count > 5 } // パスワードのバリデーション
                .sink { self.isPasswordValid = $0 } // パスワードのバリデーション結果の通知
                .store(in: &cancellables)

            // パスワード確認欄の入力値とパスワード欄の入力値を受け取り
            // 結果をisPasswordConfirmValidに反映させている
            passwordConfirmTextDidChangePublisher
                .combineLatest(passwordTextDidChangePublisher)
                .map { passwordText, confirmText in
                    passwordText == confirmText && self.isPasswordValid
                }
                .sink { self.isPasswordCofirmValid = $0 }
                .store(in: &cancellables)
        }

        // IDバリデーションのリクエスト中にインジケータを表示する
        // 終わったら消す
        $idValidatioRequesting
            .sink { [self] requesting in
            if registerButton.isEnabled {
                registerButton.isEnabled = false
            }
            requesting ?
                idValidationIndicator.startAnimating()
                : idValidationIndicator.stopAnimating()
        }.store(in: &cancellables)

        // registerButtonを押された時にAPIリクエストを送り、結果を受け取っている
        // UIControlのイベントを直接Publisherにする方法は提供されていません(UIControl+Combine.swiftを参照ください)
        registerButton.publisher(for: .touchUpInside)
            .handleEvents(receiveOutput: { self.registerRequesting = true })
            .flatMap { self.api.register() }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: isRegisterSucceeded.send)
            .store(in: &cancellables)

        // register APIのリクエスト中かどうかで画面の表示を変更している
        $registerRequesting
            .sink { [self] requesting in
                requesting ?
                    startRegisterRequest()
                    : stopRegisterRequest()
        }.store(in: &cancellables)

        // register APIの結果から画面を変更している
        isRegisterSucceeded
            .sink(receiveValue: showRegisterResult)
            .store(in: &cancellables)
    }

    private func startRegisterRequest() {
        view.isUserInteractionEnabled = false
        view.addSubview(registerLoadingView)
        registerLoadingView.frame = view.bounds
        registerIndicator.startAnimating()
    }

    private func stopRegisterRequest() {
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
            .init(title: "OK", style: .default) { _ in
                self.registerRequesting = false
        })
        present(alert, animated: true)
    }
}

// MARK: - API

struct DummyAPI {
    func validateId(_ text: String) -> AnyPublisher<Bool, Never> {
        Deferred {
            Future { promise in
                DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                    promise(.success(text.count > 5))
                }
            }
        }.eraseToAnyPublisher()
    }

    func register() -> AnyPublisher<Bool, Never> {
        Deferred {
            Future { promise in
                DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                    promise(.success(Int.random(in: 0...1000).isMultiple(of: 2)))
                }
            }
        }.eraseToAnyPublisher()
    }
}

//override func viewDidLoad() {
//    super.viewDidLoad()
//
//    $isIdValid.sink { [self] isValid in
//        let image = isValid ? validCheckImage : inValidCheckImage
//        idValidCheckImageView.image = image
//    }
////    .store(in: &cancellables)
//}
