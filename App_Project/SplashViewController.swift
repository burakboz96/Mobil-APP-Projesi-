import UIKit

class SplashViewController: UIViewController {
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Hoş Geldiniz!"
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textColor = .systemBlue
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .systemBlue
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(welcomeLabel)
        view.addSubview(loadingIndicator)
        
        setupConstraints()
        navigateToLoginScreen()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            welcomeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            
            loadingIndicator.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 20),
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func navigateToLoginScreen() {
        // 2 saniye boyunca yüklenme animasyonu
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let loginVC = LoginViewController()
            loginVC.modalTransitionStyle = .crossDissolve
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: true, completion: nil)
        }
    }
}

