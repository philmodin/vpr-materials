
import UIKit

class AcronymDetailTableViewController: UITableViewController {
  // MARK: - Properties
  var acronym: Acronym {
    didSet {
      updateAcronymView()
    }
  }

  var user: User? {
    didSet {
      updateAcronymView()
    }
  }

  var categories: [Category] {
    didSet {
      updateAcronymView()
    }
  }

  // MARK: - Initializers
  required init?(coder: NSCoder) {
    fatalError("init(coder:) is not implemented")
  }

  init?(coder: NSCoder, acronym: Acronym) {
    self.acronym = acronym
    self.categories = []
    super.init(coder: coder)
  }

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.prefersLargeTitles = false
    getAcronymData()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    getAcronymData()
  }

  // MARK: - Model Loading

  func getAcronymData() {
		guard let id = acronym.id else { return }
		let acronymDetailRequester = AcronymRequest(acronymID: id)
		acronymDetailRequester.getUser { [weak self] result in
			switch result {
			case .success(let user):
				self?.user = user
			case .failure:
				let message = "There was an error getting the acronym's user"
				ErrorPresenter.showError(message: message, on: self)
			}
		}
		acronymDetailRequester.getCategories { [weak self] result in
			switch result {
			case .success(let categories):
				self?.categories = categories
			case .failure:
				let message = "There was an error getting the acronym's categories"
				ErrorPresenter.showError(message: message, on: self)
			}
		}
  }

  func updateAcronymView() {
    DispatchQueue.main.async { [weak self] in
      self?.tableView.reloadData()
    }
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "EditAcronymSegue" {
			guard let destination = segue.destination as? CreateAcronymTableViewController else { return }
			destination.selectedUser = user
			destination.acronym = acronym
		}
  }

  @IBSegueAction func makeAddToCategoryController(_ coder: NSCoder) -> AddToCategoryTableViewController? {
    AddToCategoryTableViewController(coder: coder, acronym: acronym, selectedCategories: categories)
  }


  // MARK: - IBActions
  @IBAction func updateAcronymDetails(_ segue: UIStoryboardSegue) {
		guard let controller = segue.source as? CreateAcronymTableViewController else { return }
		user = controller.selectedUser
		if let acronym = controller.acronym { self.acronym = acronym }
  }
}

// MARK: - UITableViewDataSource
extension AcronymDetailTableViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 5
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return section == 3 ? categories.count : 1
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "AcronymDetailCell", for: indexPath)
    switch indexPath.section {
    case 0:
      cell.textLabel?.text = acronym.short
    case 1:
      cell.textLabel?.text = acronym.long
    case 2:
      cell.textLabel?.text = user?.name
    case 3:
      cell.textLabel?.text = categories[indexPath.row].name
		case 4:
			cell.textLabel?.text = "Add To Category"
    default:
      break
    }
		if indexPath.section == 4 {
			cell.selectionStyle = .default
			cell.isUserInteractionEnabled = true
		} else {
			cell.selectionStyle = .none
			cell.isUserInteractionEnabled = false
		}
    return cell
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0:
      return "Acronym"
    case 1:
      return "Meaning"
    case 2:
      return "User"
    case 3:
      return "Categories"
    default:
      return nil
    }
  }
}
