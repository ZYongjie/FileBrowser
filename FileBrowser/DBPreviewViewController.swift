//
//  DBPreviewViewController.swift
//  FileBrowser
//
//  Created by yongjie_zou on 2018/5/21.
//

import UIKit

class DBPreviewViewController: UIViewController {
    let file: FBFile?
    let dbManager: DBManager?
    let table = UITableView.init(frame: CGRect.zero, style: .plain)

    init(file:FBFile?) {
        self.file = file
        self.dbManager = file != nil ? DBManager(file: file!) : nil
        super.init(nibName:nil, bundle:nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = file?.displayName
        self.view.backgroundColor = UIColor.white;
        setupSubviews()
    }
    
    func setupSubviews() -> Void {
        table.frame = self.view.bounds
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: String.init(describing: UITableViewCell.self))
        self.view.addSubview(table)
    }
}

extension DBPreviewViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dbManager?.tables != nil ? (dbManager!.tables!.count) : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = dbManager?.tables![indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tableViewController = DBTableViewController.init(dbManager: dbManager!, index: indexPath.row)
        self.navigationController?.pushViewController(tableViewController, animated: true)
    }
}
