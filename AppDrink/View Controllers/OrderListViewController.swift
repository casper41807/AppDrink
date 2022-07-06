//
//  OrderListViewController.swift
//  DrinkApp
//
//  Created by 陳秉軒 on 2022/5/9.
//

import UIKit
import Kingfisher
import FirebaseAuth

class OrderListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource {
    
        

    
    @IBOutlet weak var ListTableView: UITableView!
    @IBOutlet weak var ListCollectionView: UICollectionView!
    
    let arrayNumber = ["1","2","3"]
    var timer:Timer?
    var index = 0
    var orderList = [DrinkOrder.Records]()
    //全部飲料總價
    var totalMoney = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        ListTableView.delegate = self
        ListTableView.dataSource = self
        ListCollectionView.dataSource = self
        ListCollectionView.delegate = self
        
        setupFlowLayout()
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(autoScrollBanner), userInfo: nil, repeats: true)
        
        fetchOrderLest()
        
        let buttonToShoppinglist = UIButton()
        buttonToShoppinglist.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonToShoppinglist)
        buttonToShoppinglist.heightAnchor.constraint(equalToConstant: 50).isActive = true
        buttonToShoppinglist.widthAnchor.constraint(equalToConstant: 100).isActive = true
        buttonToShoppinglist.trailingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30).isActive = true
        buttonToShoppinglist.bottomAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30).isActive = true
        buttonToShoppinglist.setTitle("訂單刪除", for: .normal)
        buttonToShoppinglist.tintColor = .white
        buttonToShoppinglist.backgroundColor = .red
        buttonToShoppinglist.setImage(UIImage(systemName: "cart.fill"), for: .normal)
        buttonToShoppinglist.layer.cornerRadius = 20
        buttonToShoppinglist.addTarget(self, action: #selector(deleteAllOrderList), for: .touchUpInside)
        
    }
    
    @objc func deleteAllOrderList(){
        if Auth.auth().currentUser?.email == "casper41807@gmail.com"{
            if orderList.count == 0{
                
            }else{
                for i in orderList{
                    deleteOrderList(urlStr:i.id ?? "錯誤")
                }
                totalMoney = 0
                orderList.removeAll()
                ListTableView.reloadData()
            }
        }else{
            let alert = UIAlertController(title: "警告", message: "你並沒有權限", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alert.addAction(action)
            present(alert, animated: true)
        }
    }
    
    
    func setupFlowLayout(){
        let flowLayout = ListCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.itemSize = CGSize(width: ListCollectionView.bounds.width, height: ListCollectionView.bounds.height)
        flowLayout?.minimumInteritemSpacing = 0
        flowLayout?.minimumLineSpacing = 0
        flowLayout?.estimatedItemSize = .zero
        flowLayout?.sectionInset = .zero
        flowLayout?.scrollDirection = .horizontal
    }
    
    @objc func autoScrollBanner(){
        index += 1
        if index < arrayNumber.count{
            ListCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
        }else if index == arrayNumber.count{
            index = 0
            ListCollectionView.scrollToItem(at:IndexPath(item: index, section: 0), at:.centeredHorizontally, animated: false)
        }
    }
    //抓取訂單資料
    func fetchOrderLest(){
        let urlStr = "https://api.airtable.com/v0/appjAvWZDqTgRklgL/OrderDrink"
        if let url = URL(string: urlStr){
            var request = URLRequest(url: url)
            request.setValue("Bearer keyGnfMCwVt6ZxYfS", forHTTPHeaderField: "Authorization")
            URLSession.shared.dataTask(with: request) { data, response, error in
                let decoder = JSONDecoder()
                if let data = data {
                    do{
                        let orderList = try decoder.decode(DrinkOrder.self, from: data)
                        self.orderList = orderList.records
                        for i in self.orderList{
                            self.totalMoney += i.fields.total
                        }
                        DispatchQueue.main.async {
                            self.ListTableView.reloadData()
                        }
                    }catch{
                        print(error)
                    }
                }
            }.resume()
        }
    }
    //刪除airTable訂單
    func deleteOrderList(urlStr:String){
        if let url = URL(string:"https://api.airtable.com/v0/appjAvWZDqTgRklgL/OrderDrink/\(urlStr)"){
            var request = URLRequest(url: url)
            request.setValue("Bearer keyGnfMCwVt6ZxYfS", forHTTPHeaderField: "Authorization")
            request.httpMethod = "DELETE"
            URLSession.shared.dataTask(with: request) { data, response, error in
                if error == nil{
                    print("刪除訂單成功")
                }else{
                    print(error ?? "失敗")
                }
            }.resume()
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderList.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OrderListTableViewCell", for: indexPath) as? OrderListTableViewCell else {return UITableViewCell()}
        let index = orderList[indexPath.row]
        cell.nameLabel.text = "\(index.fields.orderName)"
        cell.titleLabel.text = "\(index.fields.drinkName),\(index.fields.mikeCap)x\(index.fields.cups)"
        if index.fields.add == nil{
            cell.subTitleLabel.text = "\(index.fields.drinkIce),\(index.fields.drinkSuger)"
        }else{
            cell.subTitleLabel.text = "\(index.fields.drinkIce),\(index.fields.drinkSuger) 加\(index.fields.add ?? "") "
        }
        cell.totalMoneyLabel.text = "$\(index.fields.total)"
        if index.fields.pic == nil{
            cell.nameImage.image = UIImage(named: "77")
        }else{
            cell.nameImage.kf.setImage(with: index.fields.pic)
        }
        
        
        
        return cell
    }
     
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let orderlist = orderList[indexPath.row]
        if orderlist.fields.orderName == dataForOrderPost.orderName{
            totalMoney -= orderlist.fields.total
            deleteOrderList(urlStr: orderlist.id ?? "error")
            orderList.remove(at: indexPath.row)
            tableView.reloadData()
        }else if Auth.auth().currentUser?.email == "casper41807@gmail.com"{
            totalMoney -= orderlist.fields.total
            deleteOrderList(urlStr: orderlist.id ?? "error")
            orderList.remove(at: indexPath.row)
            tableView.reloadData()
        }else{
            let alert = UIAlertController(title: "錯誤", message: "請勿刪除別人的訂單", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alert.addAction(action)
            present(alert, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "                                         總金額:$\(totalMoney)"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
            header.textLabel?.font = UIFont.systemFont(ofSize: 22)
            header.textLabel?.textColor = .black
    }
     
    
        
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayNumber.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderListCollectionViewCell", for: indexPath) as? OrderListCollectionViewCell else {return UICollectionViewCell()}
        let index = arrayNumber[indexPath.item]
        cell.drinkImage.image = UIImage(named:index)
        return cell
    }

}
