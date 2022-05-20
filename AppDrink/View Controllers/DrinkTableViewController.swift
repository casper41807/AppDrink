//
//  DrinkTableViewController.swift
//  DrinkApp
//
//  Created by 陳秉軒 on 2022/5/4.
//

import UIKit

class DrinkTableViewController: UITableViewController {
    
    var drink = [DrinkMenu.Records]()
    var drink1 = [DrinkMenu.Records]()
    var drink2 = [DrinkMenu.Records]()
    var drink3 = [DrinkMenu.Records]()
    var drink4 = [DrinkMenu.Records]()
    var drink5 = [DrinkMenu.Records]()
    var total = [[DrinkMenu.Records]]()
    var category = ["果然好韻","好韻那堤","在地好韻","好韻特調","醇韻奶香"]
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDrinkMenu()

        let buttonToShoppinglist = UIButton()
        buttonToShoppinglist.translatesAutoresizingMaskIntoConstraints = false
        tableView.addSubview(buttonToShoppinglist)
        buttonToShoppinglist.heightAnchor.constraint(equalToConstant: 50).isActive = true
        buttonToShoppinglist.widthAnchor.constraint(equalToConstant: 100).isActive = true
        buttonToShoppinglist.trailingAnchor.constraint(greaterThanOrEqualTo: tableView.safeAreaLayoutGuide.trailingAnchor, constant: -30).isActive = true
        buttonToShoppinglist.bottomAnchor.constraint(greaterThanOrEqualTo: tableView.safeAreaLayoutGuide.bottomAnchor, constant: -30).isActive = true
        buttonToShoppinglist.setTitle("訂單", for: .normal)
        buttonToShoppinglist.tintColor = .white
        buttonToShoppinglist.backgroundColor = .black
        buttonToShoppinglist.setImage(UIImage(systemName: "cart.fill"), for: .normal)
        buttonToShoppinglist.layer.cornerRadius = 20
        buttonToShoppinglist.addTarget(self, action: #selector(showList), for: .touchUpInside)
        
       title = "Menu"
        print(dataForOrderPost.orderName)
    }
   
    
    
    @objc func showList(){
        if let controller = storyboard?.instantiateViewController(withIdentifier: "OrderListViewController") {
            present(controller, animated: true, completion: nil)
        }
    }

    
    @IBSegueAction func showDetail(_ coder: NSCoder) -> DetailTableViewController? {
        let controller = DetailTableViewController(coder: coder)
        if let selected = tableView.indexPathForSelectedRow?.section,let row = tableView.indexPathForSelectedRow?.row{
            controller?.selected = selected
            controller?.row = row
        }
        controller?.total = total
        return controller
    }
    
    
    
    
    func fetchDrinkMenu(){
        let urlStr = "https://api.airtable.com/v0/appjAvWZDqTgRklgL/Drink?sort[][field]=number&sort[][direction]=asc"
        if let url = URL(string: urlStr) {
            var request = URLRequest(url: url)
            request.setValue("Bearer keyGnfMCwVt6ZxYfS", forHTTPHeaderField: "Authorization")
            request.httpMethod = "GET"
            URLSession.shared.dataTask(with: request) { [self] data, response, error in
                let decoder = JSONDecoder()
                if let data = data {
                    do{
                        let drinkMenu = try decoder.decode(DrinkMenu.self, from: data)
                        self.drink = drinkMenu.records
                        for i in 0...8{
                            drink1.append(drink[i])
                        }
                        for i in 9...16{
                            drink2.append(drink[i])
                        }
                        for i in 17...20{
                            drink3.append(drink[i])
                        }
                        for i in 21...26{
                            drink4.append(drink[i])
                        }
                        for i in 27...31{
                            drink5.append(drink[i])
                        }
                        total = [drink1,drink2,drink3,drink4,drink5]
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }catch{
                        print(error)
                    }
                }
            }.resume()
        }
    }
    
    
//    let url = URL(string: "https://api.airtable.com/v0/appjAvWZDqTgRklgL/Drink?maxRecords=3&view=Grid%20view" )!
//    var request = URLRequest(url: url)
//    request.setValue("Bearer keyGnfMCwVt6ZxYfS", forHTTPHeaderField: "Authorization")
//    URLSession.shared.dataTask(with: request) { (data, response, error) in
//        if let data = data,
//           let content = String(data: data, encoding: .utf8) {
//            print(content)
//        }
//    }.resume()
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return total.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return total[section].count
//        switch section{
//        case 0:
//            return drink1.count
//        case 1:
//            return drink2.count
//
//        default:
//            return drink3.count
//        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DrinkTableViewCell", for: indexPath) as? DrinkTableViewCell else{return UITableViewCell()}
        
        
        let index = total[indexPath.section][indexPath.row]
        
        
        cell.nameLabel.text = "\(index.fields.name)"
        cell.priceLabel.text = "\(index.fields.price)"
        if index.fields.mikeCapPrice == nil{
            cell.mikeCapLabel.text = "無"
        }else{
            cell.mikeCapLabel.text = "\(index.fields.mikeCapPrice ?? 0)"
        }
        URLSession.shared.dataTask(with: index.fields.imageUrl) { data, response, error in
            if let data = data {
                DispatchQueue.main.async {
                    cell.drinkImage.image = UIImage(data: data)
                }
            }
        }.resume()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return category[section]
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
      guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont.systemFont(ofSize: 24)
        switch section{
        case 0:
            header.textLabel?.textColor = .orange
        case 1:
            header.textLabel?.textColor = .brown
        case 2:
            header.textLabel?.textColor = .red
        case 3:
            header.textLabel?.textColor = UIColor(red: 106/255, green: 117/255, blue: 19/255, alpha: 1)
        default:
            header.textLabel?.textColor = UIColor(red: 212/255, green: 152/255, blue: 95/255, alpha: 1)
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
