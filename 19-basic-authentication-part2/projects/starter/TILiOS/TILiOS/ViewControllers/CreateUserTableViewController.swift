
import UIKit

class CreateUserTableViewController: UITableViewController {
  // MARK: - IBOutlets
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var emailTextField: UITextField!

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    nameTextField.becomeFirstResponder()
  }

  // MARK: - IBActions
  @IBAction func cancel(_ sender: Any) {
    navigationController?.popViewController(animated: true)
  }

  @IBAction func save(_ sender: Any) {
    guard 
      let name = nameTextField.text, 
      !name.isEmpty 
    else {
      ErrorPresenter.showError(message: "You must specify a name", on: self)
      return
    }

    guard 
      let username = usernameTextField.text, 
      !username.isEmpty 
    else {
      ErrorPresenter.showError(message: "You must specify a username", on: self)
      return
    }

    guard 
      let password = passwordTextField.text, 
      !password.isEmpty 
    else {
      ErrorPresenter.showError(message: "You must specify a password", on: self)
      return
    }

		guard let email = emailTextField.text, !email.isEmpty else {
			ErrorPresenter.showError(message: "You must specify an email", on: self)
			return
		}
    let user = CreateUserData(name: name, username: username, password: password, email: email)
    ResourceRequest<User>(resourcePath: "users").save(user) { [weak self] result in
      switch result {
      case .failure:
        let message = "There was a problem saving the user"
        ErrorPresenter.showError(message: message, on: self)
      case .success:
        DispatchQueue.main.async { [weak self] in
          self?.navigationController?
            .popViewController(animated: true)
        }
      }
    }
  }
}
