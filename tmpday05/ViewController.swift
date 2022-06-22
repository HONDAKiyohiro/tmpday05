//
//  ViewController.swift
//  tmpday05
//
//  Created by Kiyohiro Honda on 2022/06/22.
//

import UIKit
import Contacts

class ViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{

    let prefectures = ["東京都", "神奈川県", "千葉県", "埼玉県", "茨城県", "栃木県", "群馬県", "北海道", "青森県", "秋田県", "岩手県", "山形県", "神奈川県", "とてもながーーーーーーーーーーーい県", "静岡県", "愛知県"]
    let tableView = UITableView()
    let button1 =  UIButton(type: UIButton.ButtonType.system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        checkAuthorizationStatus()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        displayUI()
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
        // Delegate設定
        tableView.delegate = self
        // DataSource設定
        tableView.dataSource = self
        // 画面に UITableView を追加
        self.view.addSubview(tableView)
 }
    
    @objc
    func deleteRecords(sender: Any){
        print("function deleteRecords is called")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.prefectures.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを作る
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.accessoryType = .checkmark
        cell.textLabel?.text = "セル\(indexPath.row + 1)は\(self.prefectures[indexPath.row])"
        cell.detailTextLabel?.text = "\(indexPath.row + 1)番目のセルの説明"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            // セルがタップされた時の処理
            print("タップされたセルのindex番号は: \(indexPath.row)")
        }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        // アクセサリボタン（セルの右にあるボタン）がタップされた時の処理
        print("タップされたアクセサリがあるセルのindex番号: \(indexPath.row)")
    }

}

