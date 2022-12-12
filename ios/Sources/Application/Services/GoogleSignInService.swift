//
//  GoogleSignInService.swift
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___
//  ___COPYRIGHT___
//

import UIKit

import QMobileUI
import QMobileAPI

import GoogleSignIn
import Prephirences

/// A service to handle google url callback.
///
/// KVC and @objc/NSObject provide a way to SDK to load this service.
@objc(GoogleSignInService)
class GoogleSignInService: NSObject {

    static var instance: GoogleSignInService = GoogleSignInService()

    fileprivate static let kPreferenceKey = "google.clientID"

    static var clientID: String {
        return preference.string(forKey: kPreferenceKey) ?? "TO_BE_DEFINED"
    }
    let config = GIDConfiguration(clientID: GoogleSignInService.clientID)

    fileprivate static var preference: PreferencesType {
        return Prephirences.sharedInstance
    }

    override init() { }

    /// KVC to provide your instance.
    override class func value(forKey key: String) -> Any? {
        guard key == "instance" else { return nil }
        return GoogleSignInService.instance
    }

}

// MARK: ApplicationService
extension GoogleSignInService: ApplicationService {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        // Register logout event to call GIDSignIn.sharedInstance.signOut()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {}

    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {}

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {}

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) {
        _ = GIDSignIn.sharedInstance.handle(url)
    }

}
