//
//  LoginForm.swift
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___
//  ___COPYRIGHT___

import UIKit
import QMobileUI
import QMobileAPI
import GoogleSignIn

@IBDesignable
open class LoginForm: QMobileUI.LoginForm {

    @IBOutlet weak var separatorView: UIView!

    lazy var btnAuthorization = GIDSignInButton()

    // MARK: Event
    /// Called after the view has been loaded. Default does nothing
    open override func onLoad() {
        btnAuthorization.isEnabled = true
    }
    /// Called when the view is about to made visible. Default does nothing
    open override func onWillAppear(_ animated: Bool) {
//        registerForAppleIDSessionChanges()
        setupAppleSignInButton()
    }
    /// Called when the view has been fully transitioned onto the screen. Default does nothing
    open override func onDidAppear(_ animated: Bool) {
    }
    /// Called when the view is dismissed, covered or otherwise hidden. Default does nothing
    open override func onWillDisappear(_ animated: Bool) {
    }
    /// Called after the view was dismissed, covered or otherwise hidden. Default does nothing
    open override func onDidDisappear(_ animated: Bool) {
    }
    /// Function call before launch standard login.
    open override func onWillLogin() {
        // Disable Sign In with Apple while basic mail login in progress
        btnAuthorization.isEnabled = false
    }
    /// Function after launching login process.
    open override func onDidLogin(result: Result<AuthToken, APIError>) {
        /// Release the disability of Sign In with Apple in case basic mail login failed
        switch result {
        case .success(let token):
            if !token.isValidToken {
                btnAuthorization.isEnabled = true
            }
        case .failure:
            btnAuthorization.isEnabled = true
        }
    }

    // MARK: - ASAuthorizationAppleIDButton

    fileprivate func setupAppleSignInButton() {

        setupViewWithTrait(traitCollection: self.traitCollection)
        btnAuthorization.frame = CGRect()
        btnAuthorization.addTarget(self, action: #selector(signIn(_:)), for: .touchDown)
        self.view.addSubview(btnAuthorization)

        btnAuthorization.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            btnAuthorization.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            btnAuthorization.bottomAnchor.constraint(equalTo: loginButton.topAnchor, constant: -56),
            btnAuthorization.widthAnchor.constraint(equalTo: loginButton.widthAnchor),
            btnAuthorization.heightAnchor.constraint(equalTo: loginButton.heightAnchor)
        ])
    }

    override open func traitCollectionDidChange (_ previousTraitCollection: UITraitCollection?) {}

    override open func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        /// Trait collection will change. Use this one so you know what the state is changing to.
        setupViewWithTrait(traitCollection: newCollection)
    }

    fileprivate func setupViewWithTrait(traitCollection: UITraitCollection) {
        if traitCollection.userInterfaceStyle == .dark {
            btnAuthorization = GIDSignInButton()
        } else {
            btnAuthorization = GIDSignInButton()
        }
    }

    @IBAction func signIn(_ sender: Any) {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
            guard error == nil else {
                // XXX error
                return
            }
            guard let result = result else {
                // XXX error
                return
            }
            guard let email = result.user.profile?.email else {
                // XXX error
                return
            }
            var parameters: [String: String] = [:]
            parameters["serverAuthCode"] = result.serverAuthCode ?? ""
            self.authentificate(login: email, parameters: parameters)
            // If sign in succeeded, display the app's main content View.
        }
    }

    @IBAction func signOut(sender: Any) {
      GIDSignIn.sharedInstance.signOut()
    }

}


// MARK: - Authentication

extension LoginForm {

    fileprivate func authentificate(login: String, parameters: [String: Any]?) {
        _ = APIManager.instance.authentificate(login: email, parameters: parameters) {  [weak self] result in

            guard let this = self else { return }

            this.onDidLogin(result: result)
            _ = this.delegate?.didLogin(result: result)

            switch result {
            case .success(let token):
                if token.isValidToken {
                    this.performTransition(this.btnAuthorization)
                }
            case .failure:
                break
            }
        }
    }

}
