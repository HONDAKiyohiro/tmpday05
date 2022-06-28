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
//    var groups: [CNGroup] = []
    let tableView = UITableView()
    let button1 =  UIButton(type: UIButton.ButtonType.system)
    let labelMessage = UILabel()
    
    struct ContactsFolder {
        enum FolderType {
            case container
            case group
            case voidGroup
        }
        var folderType: FolderType
        var id: String
        var nameOfContainer: String
        var nameOfGroup: String
        var shouldBeDeleted: Bool = false
    }
    var contactsFolders: [ContactsFolder] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        checkAuthorizationStatus()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        displayUI()
        refreshGroupTable()
    }

    
    
    func displayUI(){
        let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0

        button1.frame = CGRect(x: 40, y:statusBarHeight + 20, width: 150, height:50)
        button1.frame.origin.x = self.view.frame.width/2 - button1.frame.size.width/2
        button1.setTitle("Clean Up!", for: UIControl.State.normal)
        button1.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        button1.titleLabel?.adjustsFontSizeToFitWidth = true
        button1.layer.cornerRadius = 10
        button1.layer.borderWidth = 1
        self.view.addSubview(button1)
        button1.addTarget(self, action: #selector(self.deleteRecords(sender:)), for: .touchUpInside)

        labelMessage.frame = CGRect(x: 40, y: Int(button1.frame.maxY) + 20, width: 300, height: 50)
        labelMessage.text = "test"
        labelMessage.backgroundColor = UIColor.cyan
        self.view.addSubview(labelMessage)
        
        tableView.frame = CGRect(
            x: 0,
            y: CGFloat(labelMessage.frame.maxY) + 20,
            width: self.view.frame.width,
            height: self.view.frame.height - labelMessage.frame.maxY - 20
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
        containers = []
        contactsFolders = []

        let store = CNContactStore()
        do {
            containers = try store.containers(matching: nil)
        } catch{
            print(error)
        }
        print("Number of containers is \(containers.count)")
        contactsFolders = []
        for container in containers {
            print("container is \(container)")
            let fetchPredicate = CNGroup.predicateForGroupsInContainer(withIdentifier: container.identifier)
            do {
                let groupsInOneContainer = try store.groups(matching: fetchPredicate)
                if (groupsInOneContainer.count == 0) {
                    // コンテナの中にグループが存在しないタイプ（ex. Exchange）
                    contactsFolders.append(ContactsFolder(folderType: .container, id: container.identifier, nameOfContainer: container.name, nameOfGroup: "グループが存在しないコンテナ"))
                } else{
                    // コンテナの中にグループが存在するタイプ　（ex. icloudや端末ローカル）
                    for group in groupsInOneContainer {
                        contactsFolders.append(ContactsFolder(folderType: .group, id: group.identifier, nameOfContainer: container.name, nameOfGroup: group.name))
                    }
                    // グループが存在するタイプはグループに属していない連絡先群も存在するだろう
                    contactsFolders.append(ContactsFolder(folderType: .voidGroup, id: "Dummy", nameOfContainer: container.name, nameOfGroup: "グループに属していない連絡先"))
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
        // ここで選択されたセルに紐づいたグループ内の連絡先（とグループ自身）を削除する
        for i in contactsFolders {
            if i.shouldBeDeleted == true {
                print("shouldBeDeleted is true in \(i.nameOfGroup)")
            }
        }
        
        // 削除が終わったら、グループ一覧を更新する
        refreshGroupTable()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactsFolders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 一つ一つのセルを作る
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.accessoryType = .none
        cell.textLabel?.text = contactsFolders[indexPath.row].nameOfGroup
        cell.detailTextLabel?.text = contactsFolders[indexPath.row].nameOfContainer != "" ? contactsFolders[indexPath.row].nameOfContainer : "ローカル"
        if contactsFolders[indexPath.row].folderType == .container {
            // コンテナ自体の削除は本アプリの対象外なので初めから選べないようにする
            cell.isUserInteractionEnabled = false
            cell.textLabel?.textColor = .lightGray
            cell.detailTextLabel?.textColor = .lightGray
            cell.contentView.alpha = 0.9
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セルがタップされた時の処理
        print("タップされたセルのindex番号は: \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if (cell?.accessoryType == .checkmark) {
            cell?.accessoryType = .none
            contactsFolders[indexPath.row].shouldBeDeleted = false
        }else{
            cell?.accessoryType = .checkmark
            contactsFolders[indexPath.row].shouldBeDeleted = true
        }
    }

    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        // アクセサリボタン（セルの右にあるボタン）がタップされた時の処理
        // この関数は、アクセサリの種類が.checkmarkの場合は呼ばれないので、
        // 内容は空でも良いのだが、将来種類を変えた時のために便宜上書いておく。
        print("タップされたアクセサリがあるセルのindex番号: \(indexPath.row)")
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

    
}
