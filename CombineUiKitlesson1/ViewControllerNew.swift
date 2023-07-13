//
//  ViewControllerNew.swift
//  CombineUiKitlesson1
//
//  Created by Artem on 13.07.2023.
//

import UIKit
import Combine


class ViewControllerNew: UIViewController {
    
    @IBOutlet weak var emailAddressField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConfirmationField: UITextField!
    @IBOutlet weak var agreeTermsSwitch: UISwitch!
    @IBOutlet weak var singUpButton: UIButton!
    
    // MARK: Subjects
    
    private var emailSubject = CurrentValueSubject<String, Never>("")
    private var passwordSubject = CurrentValueSubject<String, Never>("")
    private var passwordConfirmatonSubject = CurrentValueSubject<String, Never>("")
    private var agreeTermSubject = CurrentValueSubject<Bool, Never>(false)
    
    private var cancellables: Set<AnyCancellable> = []
     // MARK: View Lifecycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        
        
        formIsValid
            .assign(to: \.isEnabled, on: singUpButton)
            .store(in: &cancellables)
        

        // Do any additional setup after loading the view.
    }

    
    private func emailIsValid(_ email: String) -> Bool {
        email.contains("@") && email.contains(".")
    }
    
    // MARK: - Publishers
    

    
    private var emailIsValid: AnyPublisher<Bool, Never> {
        emailSubject
            .map { [weak self] in self?.emailIsValid($0) }
            .replaceNil(with: false)
            .eraseToAnyPublisher()
    }
    
    private var formIsValid: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest3(emailIsValid, passwordValidAndConfirmed, switchOk)
            .map { $0.0 && $0.1 && $0.2 }
            .eraseToAnyPublisher()
    }
    
    private var passwordIsValid: AnyPublisher<Bool, Never> {
        passwordSubject
            .map { $0 != "password" && $0.count >= 8}
            .eraseToAnyPublisher()
    }
    
    private var passwordMatchesConfirmation: AnyPublisher<Bool, Never> {
        passwordSubject.combineLatest(passwordConfirmatonSubject)
            .map { pass, conf in
                pass == conf
            }
            .eraseToAnyPublisher()
    }
    
    private var passwordValidAndConfirmed: AnyPublisher<Bool, Never> {
        passwordIsValid.combineLatest(passwordMatchesConfirmation)
            .map { valid, confirmed in
                valid && confirmed
            }
            .eraseToAnyPublisher()
    }
    
    
    private var switchOk: AnyPublisher<Bool, Never> {
        agreeTermSubject
            .map { $0 }
            .eraseToAnyPublisher()
    }
    
    @IBAction func emailDidChange(_ sender: Any) {
        emailSubject.send(emailAddressField.text ?? "" )
    }
 
    @IBAction func passwordDidChange(_ sender: Any) {
        passwordSubject.send(passwordField.text ?? "")
    }
    
   
    

    
    @IBAction func passwordConfirmationDidChange(_ sender: Any) {
        passwordConfirmatonSubject.send(passwordConfirmationField.text ?? "")
    }
    
    
    @IBAction func agreeSwitchDidChange(_ sender: Any) {
       // view.backgroundColor = agreeTermsSwitch.isOn ? .green : .blue
        agreeTermSubject.send(agreeTermsSwitch.isOn)
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
      
    }
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
