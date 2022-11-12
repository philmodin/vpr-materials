
import UIKit

class LoginTableViewController: UITableViewController {
  // MARK: - Properties
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!

  @IBAction func loginTapped(_ sender: UIBarButtonItem) {
    guard 
      let username = usernameTextField.text, 
      !username.isEmpty 
    else {
      ErrorPresenter.showError(message: "Please enter your username", on: self)
      return
    }

    guard 
      let password = passwordTextField.text, 
      !password.isEmpty 
    else {
      ErrorPresenter.showError(message: "Please enter your password", on: self)
      return
    }
		Auth().login(username: username, password: password) { result in
			switch result {
			case .success:
				DispatchQueue.main.async {
					let appDelegate = UIApplication.shared.delegate as? AppDelegate
					appDelegate?.window?.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
				}
			case .failure:
				let message = "Could not log in. Check your credentials and try again"
				ErrorPresenter.showError(message: message, on: self)
			}
		}
  }
}
