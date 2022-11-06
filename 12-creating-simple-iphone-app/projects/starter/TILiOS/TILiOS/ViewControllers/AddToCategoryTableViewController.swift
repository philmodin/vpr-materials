import UIKit

class AddToCategoryTableViewController: UITableViewController {
  // MARK: - Properties
  private var categories: [Category] = []
  private let selectedCategories: [Category]
  private let acronym: Acronym

  // MARK: - Initialization
  required init?(coder: NSCoder) {
    fatalError("init(coder:) is not implemented")
  }

  init?(coder: NSCoder, acronym: Acronym, selectedCategories: [Category]) {
    self.acronym = acronym
    self.selectedCategories = selectedCategories
    super.init(coder: coder)
  }

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    loadData()
  }

  func loadData() {
  }
}

// MARK: - UITableViewDataSource
extension AddToCategoryTableViewController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categories.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let category = categories[indexPath.row]

    let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
    cell.textLabel?.text = category.name

    let isSelected = selectedCategories.contains { element in
      element.name == category.name
    }

    if isSelected {
      cell.accessoryType = .checkmark
    }

    return cell
  }
}
