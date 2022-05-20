//
//  UserViewController.swift
//  DrinkApp
//
//  Created by 陳秉軒 on 2022/5/11.
//

import UIKit
import FirebaseAuth


class UserViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var fbOutlet: UIButton!
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        overrideUserInterfaceStyle = .light
        emailTextField.text = ""
        passwordTextField.text = ""
        do{
            try Auth.auth().signOut()
        }catch{
            print(error)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backButtonTitle = "登出"
        fbOutlet.layer.cornerRadius = 20
        
        
        if let user = Auth.auth().currentUser {
            print("\(user.uid) login")
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "DrinkTableViewController"){
                self.navigationController?.pushViewController(controller, animated: true)
                dataForOrderPost.orderName = user.displayName ?? "error"
            }
        } else {
            print("not login")
        }
        
        
//        let loginButton = FBLoginButton()
//                loginButton.center = view.center
//                view.addSubview(loginButton)
        
        
        
//        if let accessToken = AccessToken.current {
//                   print("\(accessToken.userID) login")
//               } else {
//                   print("not login")
//               }
    }
    //點return收鍵盤
    @IBAction func dissMissKB(_ sender: Any) {
    }
    //點擊空白收鍵盤
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            view.endEditing(true)
        }
    
    
    @IBAction func fbButton(_ sender: UIButton) {
//        let manager = LoginManager()
//              manager.logIn { (result) in
//                 if case LoginResult.success(granted: _, declined: _, token: _) = result {
//                        print("login ok")
//                    } else {
//                        print("login fail")
//                    }
//              }
//        let manager = LoginManager()
//        manager.logIn(permissions: [.publicProfile, .email]) { (result) in
//              if case LoginResult.success(granted: _, declined: _, token: _) = result {
//                  print("login ok")
//              } else {
//                  print("login fail")
//              }
//        }
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
