//
//  DetailTableViewController.swift
//  DrinkApp
//
//  Created by 陳秉軒 on 2022/5/5.
//

import UIKit
import FirebaseAuth

class DetailTableViewController: UITableViewController {

    @IBOutlet weak var headerView: headerForMenu!
    @IBOutlet weak var drinkImageView: UIImageView!
    @IBOutlet weak var drinkName: UILabel!
    
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var totalMoneyLabel: UILabel!
    @IBOutlet weak var stepperOutlet: UIStepper!
    @IBOutlet weak var cupLabel: UILabel!
    @IBOutlet weak var orderOutlet: UIButton!
    
    
    var stepperNum = 1
    //從第一頁傳過來的值
    var total = [[DrinkMenu.Records]]()
    var selected = 0
    var row = 0
    
    
    var category = ["加蓋","溫度","甜度","加料"]
    let mikeCap = ["正常","奶蓋"]
    let ice = ["正常","少冰","微冰","去冰","熱"]
    let suger = ["正常","少糖","半糖","微糖","無糖"]
    let add = ["珍珠","椰果","愛玉","西米露","布丁","蜂蜜","寒天"]
    var drinkChoose = [[String]]()
//    var order = DrinkOrder(records: [.init(fields: .init(orderName: "", drinkName: total[selected][row].fields.name , mikeCap: "", drinkSuger: "", drinkIce: "", add: "", total: 0, cups: 0))])
    //記錄加料內容
    var addStr = ""
    //有無加奶蓋價錢
    var mikeCapMoney = 0
    //加料價錢
    var addMoney = 0
    //使用者照片url
    var pic:URL?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        
        URLSession.shared.dataTask(with: total[selected][row].fields.imageUrl) { data, response, error in
            if let data = data {
                DispatchQueue.main.async {
                    self.drinkImageView.image = UIImage(data: data)
                }
            }
        }.resume()
        
        if selected == 0{
            drinkName.textColor = .orange
        }else if selected == 1{
            drinkName.textColor = .brown
        }else if selected == 2{
            drinkName.textColor = .red
        }else if selected == 3{
            drinkName.textColor = UIColor(red: 106/255, green: 117/255, blue: 19/255, alpha: 1)
        }else{
            drinkName.textColor = UIColor(red: 212/255, green: 152/255, blue: 95/255, alpha: 1)
        }
        drinkName.text = total[selected][row].fields.name
        dataForOrderPost.drinkName = total[selected][row].fields.name
        arrayAdd()
        
        
        orderOutlet.layer.cornerRadius = 20
        
        
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        footerView.leadingAnchor.constraint(equalTo: tableView.frameLayoutGuide.leadingAnchor).isActive = true
        footerView.trailingAnchor.constraint(equalTo: tableView.frameLayoutGuide.trailingAnchor).isActive = true
        footerView.bottomAnchor.constraint(equalTo: tableView.frameLayoutGuide.bottomAnchor).isActive = true
        
//        dataForOrderPost.orderName = "casper"
        
    }
    
    //選購完回前一頁清除所有dataForOrderPost內記錄資料，除了訂購姓名
    override func viewWillDisappear(_ animated: Bool) {
        dataForOrderPost.clearAll()
    }

    @IBAction func stepperAction(_ sender: UIStepper) {
        cupLabel.text = "\(Int(sender.value))"
        totalMoneyLabel.text = "\((mikeCapMoney + addMoney)*Int(sender.value))"
    }
    
    @IBAction func orderPostButton(_ sender: UIButton) {
        addStr = ""
        for i in dataForOrderPost.add{
            addStr += "\(i)、"
        }
        if addStr != ""{
            addStr.removeLast()
        }
        
        if dataForOrderPost.mikeCap == ""{
            alert(title:"您未完成填選", message: "請選擇是否加蓋")
        }else if dataForOrderPost.drinkIce == "" || dataForOrderPost.drinkSuger == ""{
            alert(title:"您未完成填選", message: "請選擇甜度冰塊")
        }else{
            let alertController = UIAlertController(title: "請確認訂單", message: "訂購大名:\(dataForOrderPost.orderName)\n品項:\(dataForOrderPost.drinkName),\(dataForOrderPost.mikeCap)*\(Int(stepperOutlet.value))\n溫度甜度:\(dataForOrderPost.drinkIce),\(dataForOrderPost.drinkSuger)\n加料:\(addStr) \n總金額:\((mikeCapMoney + addMoney)*Int(stepperOutlet.value))元", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確定", style: .default) { _ in
                self.orderPost()
                self.dismiss(animated: true)
//                self.navigationController?.popViewController(animated: true)
            }
            let noAction = UIAlertAction(title: "我再想想", style: .default)
            alertController.addAction(okAction)
            alertController.addAction(noAction)
            present(alertController, animated: true)
        }
            
        
    }
    
    
    //上傳訂單資料
    func orderPost(){
        //Firebase獲取用戶圖片網址
        if let user = Auth.auth().currentUser {
            pic = user.photoURL
            print("\(String(describing: user.photoURL))123")
        }
        //總金額乘上杯數
        let totalMoney = (mikeCapMoney + addMoney)*Int(stepperOutlet.value)
        
        let order = DrinkOrder(records: [.init(id: nil, fields: .init(orderName: dataForOrderPost.orderName, drinkName: dataForOrderPost.drinkName, mikeCap: dataForOrderPost.mikeCap, drinkSuger: dataForOrderPost.drinkSuger, drinkIce: dataForOrderPost.drinkIce, add: addStr, total: totalMoney, cups: Int(stepperOutlet.value),pic:pic))])
        
        let urlStr = "https://api.airtable.com/v0/appjAvWZDqTgRklgL/OrderDrink"
        if let url = URL(string: urlStr){
            var request = URLRequest(url: url)
            request.setValue("Bearer keyGnfMCwVt6ZxYfS", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "Post"
            let encoder = JSONEncoder()
            request.httpBody = try?encoder.encode(order)
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    //印出上傳資料data
                    let content = String(data: data, encoding: .utf8)
                            print(content ?? "123")
                }
            }.resume()
        }
    }
    
    //                    let decoder = JSONDecoder()
    //                    do{
    //                        let response = try decoder.decode(DrinkOrder.self, from: data)
    //                        print(response.records[0].fields.drinkName)
    //                    }catch{
    //                        print(error)
    //                    }
    
    
    func alert(title:String,message:String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "ok", style: .default)
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }
    
    func arrayAdd(){
        drinkChoose.append(mikeCap)
        drinkChoose.append(ice)
        drinkChoose.append(suger)
        drinkChoose.append(add)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return drinkChoose.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return drinkChoose[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTableViewCell", for: indexPath) as? DetailTableViewCell else {return UITableViewCell()}
        let index = drinkChoose[indexPath.section][indexPath.row]
        cell.chooseLabel.text = index
        if indexPath.section == 0{
            if indexPath.row == 0{
                cell.moneyLabel.text = "$\(total[selected][row].fields.price)"
            }else{
                if total[selected][row].fields.mikeCapPrice == nil{
                    cell.moneyLabel.text = "無"
                }else{
                    cell.moneyLabel.text = "$\(total[selected][row].fields.mikeCapPrice ?? 0)"
                }
            }
        }else if indexPath.section == 3{
            switch indexPath.row{
            case 0,1,2,3:
                cell.moneyLabel.text = "+ $5"
            default:
                cell.moneyLabel.text = "+ $10"
            }
        }else{
            cell.moneyLabel.text = "+ $0"
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          let drinkchoose = drinkChoose[indexPath.section]
          
          switch drinkchoose{
          case mikeCap:
              if indexPath.row == 0{
                  mikeCapMoney = total[selected][row].fields.price
                  totalMoneyLabel.text = "\((mikeCapMoney + addMoney)*Int(stepperOutlet.value))"
                  dataForOrderPost.mikeCap = "正常"
              }else{
                  if total[selected][row].fields.mikeCapPrice == nil{
                      let alertController = UIAlertController(title: "錯誤", message: "此品項不能加奶蓋", preferredStyle: .alert)
                      let alertAction = UIAlertAction(title: "確認", style: .default) { _ in
                          tableView.deselectRow(at: indexPath, animated: false)
                      }
                      alertController.addAction(alertAction)
                      present(alertController, animated: true, completion: nil)
                      mikeCapMoney = 0
                      totalMoneyLabel.text = "\((mikeCapMoney + addMoney)*Int(stepperOutlet.value))"
                      dataForOrderPost.mikeCap = ""
                  }else{
                      mikeCapMoney = total[selected][row].fields.mikeCapPrice ?? 0
                      totalMoneyLabel.text = "\((mikeCapMoney + addMoney)*Int(stepperOutlet.value))"
                      dataForOrderPost.mikeCap = "奶蓋"
                  }
              }
          case ice:
              switch indexPath.row{
              case 4:
                  if total[selected][row].fields.iceOnly == "true"{
                      let alertController = UIAlertController(title: "此品項不做熱飲", message: "請選擇其他項目", preferredStyle: .alert)
                      let alertAction = UIAlertAction(title: "確認", style: .default) { _ in
                          tableView.deselectRow(at: indexPath, animated: false)
                    }
                    alertController.addAction(alertAction)
                    present(alertController, animated: true, completion: nil)
                    dataForOrderPost.drinkIce = ""
                    print("123")
                }else{
                    dataForOrderPost.drinkIce = drinkChoose[indexPath.section][indexPath.row]
                    print(dataForOrderPost.drinkIce)
                }
            default:
                dataForOrderPost.drinkIce = drinkChoose[indexPath.section][indexPath.row]
                print(dataForOrderPost.drinkIce)
            }
        case suger:
            dataForOrderPost.drinkSuger = drinkChoose[indexPath.section][indexPath.row]
            print(dataForOrderPost.drinkSuger)
        case add:
            dataForOrderPost.add.append("\(drinkChoose[indexPath.section][indexPath.row])")
            switch indexPath.row{
            case 0,1,2,3:
                addMoney += 5
                totalMoneyLabel.text = "\((mikeCapMoney + addMoney)*Int(stepperOutlet.value))"
            default:
                addMoney += 10
                totalMoneyLabel.text = "\((mikeCapMoney + addMoney)*Int(stepperOutlet.value))"
            }
            
            print(dataForOrderPost.add)
        default:
            break
        }
    }
    
   
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        switch indexPath.section{
        case 0:
            mikeCapMoney = 0
            totalMoneyLabel.text = "\((mikeCapMoney + addMoney)*Int(stepperOutlet.value))"
            dataForOrderPost.mikeCap = ""
        case 1:
            dataForOrderPost.drinkIce = ""
        case 2:
            dataForOrderPost.drinkSuger = ""
        case 3:
            if dataForOrderPost.add.contains(drinkChoose[indexPath.section][indexPath.row]){
                let index = dataForOrderPost.add.firstIndex(of: drinkChoose[indexPath.section][indexPath.row])
                dataForOrderPost.add.remove(at: index ?? 0)
            }
            switch indexPath.row{
            case 0,1,2,3:
                addMoney -= 5
                totalMoneyLabel.text = "\((mikeCapMoney + addMoney)*Int(stepperOutlet.value))"
            default:
                addMoney -= 10
                totalMoneyLabel.text = "\((mikeCapMoney + addMoney)*Int(stepperOutlet.value))"
            }
            
            print(dataForOrderPost.add)
        default:
            break
        }
    }
    //除了加料section其他section都只能單選
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
            switch indexPath.section{
            case 0,1,2:
                if let selectIndexPathInSection = tableView.indexPathsForSelectedRows?.first(where: {
                    $0.section == indexPath.section
                }) {
                 tableView.deselectRow(at: selectIndexPathInSection, animated: false)
                }
                return indexPath

            default:
                return indexPath
            }
        }
    
    
    
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return category[section]
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
            header.textLabel?.font = UIFont.systemFont(ofSize: 30)
    }
    
//    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        return footerView
//    }
//    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        switch section{
//        case 0,1,2:
//            return 0
//        default:
//            return 100
//        }
//    }
    
//    override func viewDidLayoutSubviews() {
//            super.viewDidLayoutSubviews()
//
//        if let headerView = tableView.tableFooterView {
//                let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
//                if height != headerView.frame.size.height {
//                    headerView.frame.size.height = height
//                    tableView.tableFooterView = headerView
//                }
//
//            }
//    }
    
    
    
    
    
    
    
    
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
