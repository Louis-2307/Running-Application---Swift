//
//  SecondScreen.swift
//  INFO6125_FinalProject
//
//  Created by Anh Dinh Le on 2022-04-10.
//

import UIKit
import FirebaseAuth

class SecondScreen: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var items: [ItemToDo] = []
    var Title: String?
    var Distance: String?
    var Duration: String?
    
    let dataPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        .first?.appendingPathComponent("recordedActivity.plist")
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print(dataPath)
        
        tableView.dataSource = self
        tableView.delegate = self
        readRecordActivity()
        addDataToItems()
        
    }
    
    // screen is locked in portrait
    override open var shouldAutorotate: Bool {
       return false
    }

    // Specify the orientation.
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
       return .portrait
    }
    
    
    @IBAction func LogoutButton(_ sender: UIBarButtonItem) {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.performSegue(withIdentifier: "goBack", sender: self)
        }
        catch let signOutError as NSError
        {
            print("Error signing out: %@", signOutError)
        }
            //dismiss(animated: true)
    }
   
    func readRecordActivity(){
        guard let RecordedFile = dataPath else{
            return
        }
        
        let decoder = PropertyListDecoder()

        do{
            let data = try Data(contentsOf: RecordedFile)
            let decodedData = try decoder.decode([ItemToDo].self, from: data)
            
//            for activity in decodedData {
//                items.append(ItemToDo(title:"\(activity.title)" , description: "\(activity.description)"))
//            }
            items = decodedData
            tableView.reloadData()
        }catch{
            print(error)
        }
    }

    func addDataToPropertyList(){
        let encoder = PropertyListEncoder()
        do{
            let data = try encoder.encode(items)
            try data.write(to: dataPath!)
        }catch{
            print(error)
        }
    }
    
    func addDataToItems(){
        guard let newTitle = Title else {
            return
        }
        guard let newDistance = Distance else {
            return
        }
        guard let newDuration = Duration else {
            return
        }
        if Duration != nil && Distance != nil && Title != nil
        {
            items.append(ItemToDo(title:"\(newTitle)", description: "Distance: \(newDistance)" + " " + "Duration: \(newDuration)"))
            Distance = nil
            Duration = nil
            Title = nil
            addDataToPropertyList()
        }
    }
    
    @IBAction func AddNewRecord(_ sender: Any) {
        self.performSegue(withIdentifier: "goToNextPage", sender: self) //"goToNextPage" is name of Identifier
    }
    
       
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                if segue.identifier == "goToNextPage"
                {
                let destination = segue.destination as! ThirdScreen
                   // destination.userEmail = emailTextField.text
                }
                else if segue.identifier == "goBack"
                {
                let destination = segue.destination as! ViewController
                }
            }
}

extension SecondScreen: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "toDoCell", for: indexPath)
        let item = items[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = item.title
        content.secondaryText = item.description
        //content.image = UIImage(systemName: "cloud")
        

        cell.contentConfiguration = content
        
        return cell
    }
}
extension SecondScreen: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let isChecked = tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark
        if (isChecked) {
            
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            removeItem(at: indexPath)
            
        }
    }
    private func removeItem(at indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Remove item",
                                                message: "Are you sure?",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: {_ in
            self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }))
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
            self.items.remove(at: indexPath.row)
            self.tableView.reloadData()
            self.addDataToPropertyList()
        }))
        self.present(alertController, animated: true)
    }
}
struct ItemToDo: Codable {
    let title: String
    let description: String
   // let icon: UIImage?
}
