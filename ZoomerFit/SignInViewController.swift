//
//  ViewController.swift
//  ZoomerFit
//
//  Created by Andrew Kang on 4/26/20.
//  Copyright © 2020 Andrew Kang. All rights reserved.
//

import UIKit
import FirebaseUI
import FBSDKLoginKit

class ViewController: UIViewController, LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton!, didCompleteWith result: LoginManagerLoginResult!, error: Error!) {
      if let error = error {
        print(error.localizedDescription)
        return
      }
      let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
    
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
    }
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let token = AccessToken.current,
            !token.isExpired {
            // User is logged in, do work such as go to next view controller.
        }
        let loginButton = FBLoginButton()
        loginButton.delegate = self
        loginButton.center = view.center
        view.addSubview(loginButton)
        loginButton.permissions = ["public_profile", "email"]

        // Do any additional setup after loading the view.
    }

    @IBAction func SignInPressed(_ sender: Any) {
        let authUI = FUIAuth.defaultAuthUI()
        
        guard authUI != nil else {
            return
        }
        authUI?.delegate = self
        authUI?.providers = [FUIEmailAuth()]
        let authViewController = authUI?.authViewController()
        present(authViewController!, animated: true, completion: nil)
    }
    
}



extension ViewController: FUIAuthDelegate {
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        
        guard error == nil else {
            print(error?.localizedDescription as Any)
            return
        }
        //authDataResult?.user.uid
        //performSegue(withIdentifier: "goHome", sender: self)
        performSegue(withIdentifier: "toTab", sender: self)
    }
}


