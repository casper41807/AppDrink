//
//  UserViewController.swift
//  DrinkApp
//
//  Created by 陳秉軒 on 2022/5/11.
//

import UIKit
import FirebaseAuth
import FacebookLogin
import GoogleSignIn


class UserViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var fbOutlet: UIButton!
    
    @IBOutlet weak var google: GIDSignInButton!
    
    let signInConfig = GIDConfiguration(clientID: "32669712464-qt5s65agc1ppl0njfuf7arpgsedalss2.apps.googleusercontent.com")
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //只提供白天模式
        overrideUserInterfaceStyle = .light
        
        emailTextField.text = ""
        passwordTextField.text = ""
        //Firebase登出
        do{
            try Auth.auth().signOut()
        }catch{
            print(error)
        }
        //fb登出
        let manager = LoginManager()
        manager.logOut()
        
       
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //google登出
        GIDSignIn.sharedInstance.signOut()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backButtonTitle = "登出"
//        fbOutlet.layer.cornerRadius = 20
        
       
        
        //確認用戶在Firebase是否登入過
        if let user = Auth.auth().currentUser {
            print("\(user.uid) login")
            if let controller = storyboard?.instantiateViewController(withIdentifier: "DrinkTableViewController"){
                self.navigationController?.pushViewController(controller, animated: true)
                dataForOrderPost.orderName = user.displayName ?? "error"
            }
        } else {
            print("Firebase not login")
        }
        //確認用戶在Facebook是否登入過
        if let accessToken = AccessToken.current,!accessToken.isExpired {
            print("\(accessToken.userID) login")
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "DrinkTableViewController"){
                Profile.loadCurrentProfile { profile, error in
                        if let profile = profile {
                            print(profile.name ?? "fb沒名字")
                            dataForOrderPost.orderName = profile.name ?? "fb沒名字"
                        }
                }
                self.navigationController?.pushViewController(controller, animated: true)
            }
        } else {
            print("Fb not login")
        }
        
//        Fb提供登入按鈕
//        let loginButton = FBLoginButton()
//                loginButton.center = view.center
//                view.addSubview(loginButton)
        
        //確認用戶在google是否登入過
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
           if error != nil || user == nil {
               print("google not login")
           } else {
               if let controller = self.storyboard?.instantiateViewController(withIdentifier: "DrinkTableViewController"),let fullName = user?.profile?.name{
                   dataForOrderPost.orderName = fullName
                   self.navigationController?.pushViewController(controller, animated: true)
               }
           }
         }
        
        
        
        
    }
    
    //點return收鍵盤
    @IBAction func dissMissKB(_ sender: Any) {
    }
    //點擊空白收鍵盤
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            view.endEditing(true)
        }
    
    //fb登入按鈕
    @IBAction func fbButton(_ sender: UIButton) {
        let manager = LoginManager()
        manager.logIn { result in
            switch result {
            case .success(granted: _, declined: _, token: _):
                print("success")
                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "DrinkTableViewController"),let _ =  AccessToken.current  {
                    Profile.loadCurrentProfile { profile, error in
                            if let profile = profile {
                                print(profile.name ?? "fb沒名字")
                                dataForOrderPost.orderName = profile.name ?? "fb沒名字"
                            }
                    }
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            case .cancelled:
                print("cancelled")
            case .failed(_):
                print("failed")
            }
        }
//        login()
    }
    //利用Firebase結合Fb登入寫法
//    func login() {
//            let manager = LoginManager()
//            manager.logIn(permissions: [.publicProfile], viewController: self) { (result) in
//                if case LoginResult.success(granted: _, declined: _, token: let token) = result {
//                    print("fb login ok")
//
//                    let credential =  FacebookAuthProvider.credential(withAccessToken: token!.tokenString)
//                        Auth.auth().signIn(with: credential) { [weak self] (result, error) in
//                        guard let self = self else { return }
//                        guard error == nil else {
//                            print(error?.localizedDescription)
//                            return
//                        }
//                        print("login ok")
//                        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "DrinkTableViewController"),let _ =  AccessToken.current  {
//                                Profile.loadCurrentProfile { profile, error in
//                                        if let profile = profile {
//                                            print(profile.name ?? "fb沒名字")
//                                            dataForOrderPost.orderName = profile.name ?? "fb沒名字"
//                                        }
//                                }
//                                self.navigationController?.pushViewController(controller, animated: true)
//                        }
//                    }
//
//                } else {
//                    print("login fail")
//                }
//            }
//    }
    
    //google登入按鈕
    @IBAction func googleLogIn(_ sender: GIDSignInButton) {
        
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
            guard error == nil else { return }
            guard let user = user else { return }

            if let fullName = user.profile?.name{
                dataForOrderPost.orderName = fullName
            }
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "DrinkTableViewController"){
                self.navigationController?.pushViewController(controller, animated: true)
            }
         }
    }
    
    
    
    @IBAction func registerButton(_ sender: UIButton) {
        navigationItem.backButtonTitle = "返回"
    }
    
    @IBAction func LogInButton(_ sender: UIButton) {
        navigationItem.backButtonTitle = "登出"

        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { [self] (user, error) in
            if error != nil {
                print(error!)
                let alert = UIAlertController(title: "登入失敗", message: error?.localizedDescription, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                    if let controller = self.storyboard?.instantiateViewController(withIdentifier: "DrinkTableViewController"),let user = Auth.auth().currentUser  {
                        self.navigationController?.pushViewController(controller, animated: true)
                        dataForOrderPost.orderName = user.displayName ?? "error"
                    }
            }
        }
    }
    
    

}
