//
//  SplashScreenViewController.swift
//  ConArtist
//
//  Created by Cameron Eldridge on 2018-02-22.
//  Copyright © 2018 Cameron Eldridge. All rights reserved.
//

import UIKit

class SplashScreenViewController: UIViewController {
    static let ID = "SplashScreen"
}

// MARK: - Lifecycle
extension SplashScreenViewController {
    override func viewDidLoad() {
        SignInViewController.show(animated: false)
        if ConArtist.API.Auth.authToken != ConArtist.API.Auth.Unauthorized {
            ConventionListViewController.show(animated: false)
            let _ = ConArtist.API.Auth.reauthorize()
                .subscribe(
                    onError: {
                        print("Sign in failed: \($0)")
                        ConArtist.model.navigate(backTo: SignInViewController.self)
                        ConArtist.API.Auth.authToken = ConArtist.API.Auth.Unauthorized
                    }
                )
        }
    }
}

// MARK: - Navigation
extension SplashScreenViewController {
    class func show() {
        let controller = SplashScreenViewController.instantiate(withId: SplashScreenViewController.ID)
        ConArtist.model.navigate(replace: controller)
    }
}
