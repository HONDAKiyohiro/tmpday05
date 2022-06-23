//
//  ViewController.swift
//  tmpday05
//
//  Created by Kiyohiro Honda on 2022/06/22.
//

import UIKit
import Contacts

class ViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{

    var containers: [CNContainer] = []
    var groups: [CNGroup] = []
    var containersArray: [String] = []
    var groupsArray: [String] = []
    let tableView = UITableView()
    let button1 =  UIButton(type: UIButton.ButtonType.system)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        checkAuthorizationStatus()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        displayUI()
        refreshGroupTable()
    }

    func checkAuthorizationStatus(){
        // 連絡帳へアクセスできることを確認し、もし出来ないならばユーザーに出来るようにせよと催す
        let status = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        switch status{
        case .notDetermined:
            // 初回アクセス時
            CNContactStore().requestAccess(for: CNEntityType.contacts){(granted, error) in
                if granted{
                }else{
                    let alert = UIAlertController(title: "アクセス権限エラー", message: "連絡先へのアクセスは必ず許可してください。[設定]-[プライバシー]-[連絡先]にてこのアプリが連絡先へアクセスすることを許可してから再度アプリを起動しなおして下さい。", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    print("case: denied by intention!")
                    self.button1.isEnabled = false
                }
            }
        case .authorized:
            // アクセス許可済
            break
        case .restricted:
            // ペアレンタルコントロール等の機能制限により利用不可
            let alert = UIAlertController(title: "アクセス権限エラー", message: "[設定]-[スクリーンタイム]にてこのアプリが連絡先へアクセスすることを許可してください", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            print("case: restricted")
            button1.isEnabled = false
        case .denied:
            // アクセス拒否済
            let alert = UIAlertController(title: "アクセス権限エラー", message: "[設定]-[プライバシー]-[連絡先]にてこのアプリが連絡先へアクセスすることを許可してください", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            print("case: denied")
            button1.isEnabled = false
        @unknown default:
            fatalError()
        }
        
    }
    
    
    func displayUI(){
        let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0

        button1.frame = CGRect(x: 40, y:50, width: 150, height:50)
        button1.frame.origin.x = self.view.frame.width/2 - button1.frame.size.width/2
        button1.setTitle("Clean Up!", for: UIControl.State.normal)
        button1.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        button1.titleLabel?.adjustsFontSizeToFitWidth = true
        button1.layer.cornerRadius = 10
        button1.layer.borderWidth = 1
        self.view.addSubview(button1)
        button1.addTarget(self, action: #selector(self.deleteRecords(sender:)), for: .touchUpInside)

        tableView.frame = CGRect(
            x: 0,
            y: statusBarHeight + 50 + button1.frame.height,
            width: self.view.frame.width,
            height: self.view.frame.height - statusBarHeight
        )
        self.view.addSubview(tableView)
        // Delegate設定
        tableView.delegate = self
        // DataSource設定
        tableView.dataSource = self
        // 画面に UITableView を追加
    }
    
    func refreshGroupTable(){
        /*
         contactstore1にアクセスして、各コンテナ内のグループを
         cellMainTitlesとcellSubTilesに設定する
        */
//      いまはダミーコードを入れておく
//        groupsArray = ["g0c0", "g1c0", "g2c0", "g0c1", "g1c1"]
//        containersArray  = ["c0", "c0", "c0", "c1", "c1"]
        let store = CNContactStore()
        do {
            containers = try store.containers(matching: nil)
        } catch{
            print(error)
        }
        print("Number of containers is \(containers.count)")
        for container in containers {
            print("container is \(container)")
            let fetchPredicate = CNGroup.predicateForGroupsInContainer(withIdentifier: container.identifier)
            do {
                let groupsInOneContainer = try store.groups(matching: fetchPredicate)
                if (groupsInOneContainer.count == 0) {
                    containersArray.append(container.name != "" ? container.name : "local")
                    groupsArray.append("グループ無し")
                } else{
                    for group in groupsInOneContainer {
                        containersArray.append(container.name != "" ? container.name : "local")
                        groupsArray.append(group.name)
                    }

                }
            } catch {
                print("Error fetching in containers")
            }
        }
        
        
        tableView.reloadData()
    }
    
    
    @objc
    func deleteRecords(sender: Any){
        print("function deleteRecords is called")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 一つ一つのセルを作る
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.accessoryType = .checkmark
        cell.textLabel?.text = groupsArray[indexPath.row]
        cell.detailTextLabel?.text = containersArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セルがタップされた時の処理
        print("タップされたセルのindex番号は: \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        // アクセサリボタン（セルの右にあるボタン）がタップされた時の処理
        // この関数は、アクセサリの種類が.checkmarkの場合は呼ばれないので、
        // 内容は空でも良いのだが、将来種類を変えた時のために便宜上書いておく。
        print("タップされたアクセサリがあるセルのindex番号: \(indexPath.row)")
    }

}

