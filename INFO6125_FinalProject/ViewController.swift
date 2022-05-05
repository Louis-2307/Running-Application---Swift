//
//  ViewController.swift
//  INFO6125_FinalProject
//
//  Created by David Garcia on 2022-04-09.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var IssueLabel: UILabel!
    
    @IBOutlet weak var EmailNewTextField: UITextField!
    @IBOutlet weak var PasswordNewTextField: UITextField!
    @IBOutlet weak var SigninButton: UIButton!
    @IBOutlet weak var IssueLabel2: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        LoginButton.isEnabled = false
        SigninButton.isEnabled = false
        IssueLabel.isHidden = true
        IssueLabel2.isHidden = true
        
       
    }
    
    // screen is locked in portrait
    override open var shouldAutorotate: Bool {
       return false
    }

    // Specify the orientation.
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
       return .portrait
    }
    
    @IBAction func EmailTextField(_ sender: UITextField) {
        if sender.text?.isEmpty == true
        {
            LoginButton.isEnabled = false
            IssueLabel.isHidden = false
            IssueLabel.text = "Email is empty"
        }
        else if sender.text?.isEmpty == false && PasswordTextField.text?.isEmpty == false
        {
            IssueLabel.isHidden = true
            LoginButton.isEnabled = true
        }
    }
    
    
    @IBAction func PasswordTextField(_ sender: UITextField) {
        if sender.text?.isEmpty == true
        {
            LoginButton.isEnabled = false
            IssueLabel.isHidden = false
            IssueLabel.text = "Password is empty"
        }
        else if sender.text?.isEmpty == false && EmailTextField.text?.isEmpty == false
        {
            IssueLabel.isHidden = true
            LoginButton.isEnabled = true
        }
    }
    
    @IBAction func EmailNewTextChanged(_ sender: UITextField) {
        if sender.text?.isEmpty == true
        {
            SigninButton.isEnabled = false
            IssueLabel2.isHidden = false
            IssueLabel2.text = "Email is empty"
        }
        else if sender.text?.isEmpty == false && PasswordNewTextField.text?.isEmpty == false
        {
            IssueLabel2.isHidden = true
            SigninButton.isEnabled = true
        }
    }
    
    @IBAction func PasswordNewTextChanged(_ sender: UITextField) {
        if sender.text?.isEmpty == true
        {
            SigninButton.isEnabled = false
            IssueLabel2.isHidden = false
            IssueLabel2.text = "Password is empty"
        }
        else if sender.text?.isEmpty == false && EmailNewTextField.text?.isEmpty == false
        {
            IssueLabel2.isHidden = true
            SigninButton.isEnabled = true
        }
    }
    
    private var userIdentifier: String?
    private let welcomeSegue: String = "goToNextPage"
    
    @IBAction func LoginButton(_ sender: UIButton) {
        let email = EmailTextField.text ?? ""
        let password = PasswordTextField.text ?? ""
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                      guard let strongSelf = self else { return }
                        if let error = error, let errorCode = AuthErrorCode(rawValue: error._code)
                        {
                            switch errorCode{
                                case .userNotFound:
                                    strongSelf.showUIAlert(setence: "user doesn't exit")
                                case .wrongPassword:
                                    strongSelf.showUIAlert(setence: "incorrect password")
                                default:
                                    strongSelf.showUIAlert(setence:"error authentication user")
                                            }
                                return
                        }
            
                            strongSelf.userIdentifier = authResult?.user.email
                            strongSelf.performSegue(withIdentifier: strongSelf.welcomeSegue, sender: strongSelf)
                    }
    }
    
    
    
    
    @IBAction func SignInButtonTapped(_ sender: UIButton) {
        let email = EmailNewTextField.text ?? ""
        let password = PasswordNewTextField.text ?? ""
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if error == nil && authResult != nil {
                self.showUIAlert(setence: "New user created")
                            
                        } else {
                            guard let message = error?.localizedDescription else { return }
                            self.showUIAlert(setence: "Error while created new user")
                            
                        }
        }
    }
    
    func showUIAlert (setence : String){
            let alert = UIAlertController(title: "Notification", message: "\(setence)", preferredStyle: .alert)
            let destructiveButton = UIAlertAction(title: "OK", style: .default)
            alert.addAction(destructiveButton)
            self.show(alert, sender: nil)
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "goToNextPage"
            {
            let destination = segue.destination as! SecondScreen
                //destination.userEmail = userIdentifier
            }
        }
}

