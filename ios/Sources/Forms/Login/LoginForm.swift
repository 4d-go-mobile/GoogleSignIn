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
import SwiftMessages

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
        btnAuthorization.addTarget(self, action: #selector(signIn(_:)), for: .touchDown)
        self.view.addSubview(btnAuthorization)

        btnAuthorization.translatesAutoresizingMaskIntoConstraints = false
        if self.traitCollection.userInterfaceStyle == .dark {
            btnAuthorization.colorScheme = .dark
        } else {
            btnAuthorization.colorScheme = .light
        }
        NSLayoutConstraint.activate([
            btnAuthorization.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8),
            btnAuthorization.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 8),
            btnAuthorization.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            btnAuthorization.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    override open func traitCollectionDidChange (_ previousTraitCollection: UITraitCollection?) {
        if self.traitCollection.userInterfaceStyle == .dark {
            btnAuthorization.colorScheme = .dark
        } else {
            btnAuthorization.colorScheme = .light
        }
    }

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
        // If the application does not support the required URL schemes tell the developer so, do not crash with google objc exeception. (other way is to have code to catch it)
        guard let externalURLSchemes = (Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [AnyObject])?
            .compactMap({ $0 as? [String: AnyObject] })
            .compactMap({ $0["CFBundleURLSchemes"] as? [String] })
            .flatMap({$0}), externalURLSchemes.contains(GoogleSignInService.expectedURLScheme) else {
            self.displayInputError(message:"Your app is missing support for the following URL schemes: \(GoogleSignInService.expectedURLScheme)")
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
            guard error == nil else {
                self.displayInputError(message: error?.localizedDescription ?? error.debugDescription)
                return
            }
            guard let result = result else {
                self.displayInputError(message: "No result from google")
                return
            }
            guard let email = result.user.profile?.email else {
                self.displayInputError(message: "No email from google")
                return
            }
            var parameters: [String: Any] = [:]
            if let serverAuthCode = result.serverAuthCode {
                parameters["serverAuthCode"] = serverAuthCode
            }
            let refreshToken = result.user.refreshToken
            parameters["refreshToken"] = ["date": refreshToken.expirationDate?.iso8601 ?? "", "token": refreshToken.tokenString]
            let accessToken = result.user.accessToken
            parameters["accessToken"] = ["date": accessToken.expirationDate?.iso8601 ?? "", "token": accessToken.tokenString]
            if let idToken = result.user.idToken {
                parameters["idToken"] = ["date": idToken.expirationDate?.iso8601 ?? "", "token": idToken.tokenString]
            }
            if let profile = result.user.profile {
                parameters["profile"] = [
                    "email": profile.email,
                    "name": profile.name,
                    "givenName": profile.givenName ?? "",
                    "familyName": profile.familyName ?? "",
                    "imageURL": profile.imageURL(withDimension: 128)?.absoluteString ?? ""
                ]
            }

            self.authentificate(login: email, parameters: parameters)
            // If sign in succeeded, display the app's main content View.
        }
    }

    @IBAction func signOut(sender: Any) {
      GIDSignIn.sharedInstance.signOut()
    }

    override open func displayInputError(message: String) {
        SwiftMessages.error(title: "", message: message)
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
