//
//  RegisterViewController.swift
//  DrinkApp
//
//  Created by 陳秉軒 on 2022/5/14.
//

import UIKit
import PhotosUI
import FirebaseAuth
import Alamofire


class RegisterViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,PHPickerViewControllerDelegate {

   
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var picLable: UILabel!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var previewImage:UIImage?
    var url:URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        
        picLable.text = "點擊選擇大頭貼\n(非必要)"
        emailTextField.text = ""
        passwordTextField.text = ""
        nameTextField.text = ""
    }
    
    //點return收鍵盤
    @IBAction func dissMissKB(_ sender: UITextField) {
    }
    //點擊空白收鍵盤
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            view.endEditing(true)
        }
    
    @IBAction func imageButton(_ sender: UIButton) {
        showSourceTypeActionSheet()
        
    }
    
    @IBAction func registerButton(_ sender: UIButton) {
        if let emailText = emailTextField.text,let passwordText = passwordTextField.text,let nameText = nameTextField.text{
            
            if nameText == ""{
                let alert = UIAlertController(title: "註冊失敗", message: "請輸入姓名", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }else{
                Auth.auth().createUser(withEmail: emailText, password: passwordText) { [self] (user, error) in
                    if error != nil {
                        print(error!)
                        let alert = UIAlertController(title: "註冊失敗", message: error?.localizedDescription, preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                    }else{
                        //  success
                        print("Registration Successful!")
                        uploadImage(uiImage: previewImage ?? UIImage(), nameText: nameText)
                        let alert = UIAlertController(title: "註冊成功", message: "請記住您的帳號以及密碼\n帳號:\(emailText)\n密碼:\(passwordText)", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .default) { [self] _ in
                            self.navigationController?.popViewController(animated: true)
                        }
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    //圖片上傳到imgur，在利用回傳讀取圖片網址
    func uploadImage(uiImage: UIImage,nameText:String) {
            let headers: HTTPHeaders = [
                "Authorization": "Client-ID 3e943d291f594f7",
            ]
            AF.upload(multipartFormData: { data in
                if let imageData = uiImage.jpegData(compressionQuality: 0.9){
                    data.append(imageData, withName: "image")
                }
                
            }, to: "https://api.imgur.com/3/image", headers: headers).responseDecodable(of: ImgurImageResponse.self, queue: .main, decoder: JSONDecoder()) { response in
                switch response.result {
                case .success(let result):
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = nameText
                    changeRequest?.photoURL = result.data.link
                    print(changeRequest?.displayName ?? "沒名字")
                    print(changeRequest?.photoURL ?? "沒照片")
                    changeRequest?.commitChanges(completion: { error in
                       guard error == nil else {
                           print(error?.localizedDescription ?? "123")
                           return
                       }
                    })
                    print(result.data.link)
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    func showSourceTypeActionSheet(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "開啟相機", style: .default) { _ in
            print("開啟相機")
            self.showCamera()
            alert.dismiss(animated: true, completion: nil)
        }
        let photoLibraryAction = UIAlertAction(title: "選擇相簿", style: .default) { _ in
            print("選擇相簿")
            self.showPhotoLibrary()
            alert.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "取消", style:.cancel) { _ in
            print("取消")
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cameraAction)
        alert.addAction(photoLibraryAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    //UIImagePickerViewController
    func showCamera(){
        if !UIImagePickerController.isSourceTypeAvailable(.camera){
            let alert = UIAlertController(title: "提醒", message: "此裝置沒有相機", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            return
        }
        let controller = UIImagePickerController()
        controller.sourceType = .camera
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
    
  
    //UIImagePickerViewControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectImage = info[.originalImage] as? UIImage{
            //取得使用者選擇圖片
            previewImage = selectImage
            self.userImage.image = selectImage
            picker.dismiss(animated: true) {
                //拍攝照片完上傳
//                self.uploadImage(uiImage: selectImage)
            }
        }else{
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    
    //PHPickerViewController
    func showPhotoLibrary(){
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    //PHPickerViewControllerDelegate
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
//        picker.dismiss(animated: true)
//
//        let itemProviders = results.map(\.itemProvider)
//        if let itemProvider = itemProviders.first, itemProvider.canLoadObject(ofClass: UIImage.self) {
//            let previousImage = self.userImage.image
//            itemProvider.loadObject(ofClass: UIImage.self) {[weak self] (image, error) in
//                DispatchQueue.main.async {
//                    guard let self = self, let image = image as? UIImage,self.userImage.image == previousImage else { return }
//                    self.userImage.image = image
//                    self.previewImage = image
//                }
//            }
//        }
        let itemProviders = results.map(\.itemProvider)
        if let itemProvider = itemProviders.first,itemProvider.canLoadObject(ofClass: UIImage.self){
            itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                DispatchQueue.main.async {
                    if let image = image as? UIImage {
                        self.previewImage = image
                        self.userImage.image = image
                        picker.dismiss(animated: true) {
                            //選擇相簿完上傳
//                            self.uploadImage(uiImage: image)
                        }
                    }
                }
            }
        }else{
            picker.dismiss(animated: true, completion: nil)
        }
    }

}
