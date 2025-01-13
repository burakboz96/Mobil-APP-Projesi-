//
//  LoginViewController 3.swift
//  App_Project
//
//  Created by Burak Bozoğlu on 9.11.2024.
//


import UIKit

class LoginViewController: UIViewController {
    
    private let loginLabel: UILabel = {
        let label = UILabel()
        label.text = "Giriş Ekranı"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(loginLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            loginLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
