//
//  DBTableViewController.swift
//  FileBrowser
//
//  Created by yongjie_zou on 2018/5/22.
//

import UIKit

class DBTableViewController: UIViewController, GridViewDelegate {
    let dbManager: DBManager
    var currentIndex: Int
    let gridView: GridView
    var data: [[DBUnitData]]
    var heightOfLine = [CGFloat]()
    let maxWidth:CGFloat = 200

    init(dbManager:DBManager, index:Int) {
        self.dbManager = dbManager
        self.currentIndex = index
        self.gridView = GridView.init(frame: CGRect.zero)
        self.data = dbManager.tableData[dbManager.tables![index]]!
        for _ in self.data {
            heightOfLine.append(40)
        }
        heightOfLine.append(40)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        if #available(iOS 11.0, *) {
//            self.gridView.collectionView.contentInsetAdjustmentBehavior = .never
//        } else {
//            self.automaticallyAdjustsScrollViewInsets = false
//        }
        self.title = dbManager.tables?[currentIndex]
        self.view.backgroundColor = UIColor.white
        self.gridView.frame = self.view.bounds;
        self.gridView.delegate = self
        self.gridView.collectionView.register(DataCell.self, forCellWithReuseIdentifier: DataCell.reuseIdentifer)
        self.view.addSubview(self.gridView)
    }
    
    func numberOfLines() -> Int {
        return data.count + 1
    }
    func numberOfColumns() -> Int {
        return data.first!.count + 1
    }
    func widthOfColumn(column: Int) -> CGFloat {
        if column > 0 {
            let key:NSString = data.first![column - 1].key! as NSString
            let value:NSString = data.first![column - 1].varlueString! as NSString

            let keyWidth = key.size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0)]).width + 4
            let valueWidth = value.size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0)]).width + 4
            return min(maxWidth, max(keyWidth, valueWidth))
        }
        return 50
    }
    func heightOfLine(line: Int) -> CGFloat {
        return heightOfLine[line]
    }
    func cellForGridView(_ gridView: GridView, column: Int, line: Int) -> UICollectionViewCell {
        let cell:DataCell = gridView.collectionView.dequeueReusableCell(withReuseIdentifier: DataCell.reuseIdentifer, for: IndexPath(row: column, section: line)) as! DataCell

        cell.backgroundColor = UIColor.white
        if column == 0 {
            cell.textLabel.text = "\(line)"
            cell.backgroundColor = UIColor.green
        }
        if line == 0 && column > 0 {
            cell.textLabel.text = data[0][column - 1].key
            cell.backgroundColor = UIColor.green
        }
        if line == 0 && column == 0 {
            cell.textLabel.text = nil
            cell.backgroundColor = UIColor.brown
        }
        if column > 0 && line > 0
        {
            cell.textLabel.text = data[line - 1][column - 1].varlueString
            cell.backgroundColor = line % 2 == 1 ? UIColor.white : UIColor.lightGray
        }
        return cell
    }
    
    func gridView(_ gridView: GridView, didSelectCell atColumn: Int, line: Int) {
//        heightOfLine[line] = 60
//        gridView.reload(line: line)
        if line == 0 && atColumn > 0 {
            let item = data.first![atColumn - 1]
            if item.type == DBUnitType.int {
                let alterController = UIAlertController.init(title: "格式转换", message: nil, preferredStyle: .alert)
                let actionToInt = UIAlertAction.init(title: "转换为整型", style: UIAlertActionStyle.default) { (actionToInt) in
                    for index in 0..<self.data.count {
                        let temp = self.data[index][atColumn - 1]
                        temp.varlueString = "\(temp.value ?? "")"
                    }
                    self.gridView.collectionView.reloadData();
                }
                let actionToString = UIAlertAction.init(title: "转换为日期", style: UIAlertActionStyle.default) { (actionToInt) in
                    for index in 0..<self.data.count {
                        let temp = self.data[index][atColumn - 1]
                        let dateFormate = DateFormatter.init()
                        dateFormate.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let date = Date.init(timeIntervalSince1970: Double(Int(temp.value as! Int32)))
                        temp.varlueString = dateFormate.string(from: date)
                    }
                    self.gridView.collectionView.reloadData()
                }
                alterController.addAction(actionToInt)
                alterController.addAction(actionToString)
                self.present(alterController, animated: true, completion: nil)
            }
        }
    }
}

class DataCell: UICollectionViewCell {
    let textLabel: UILabel
    static let reuseIdentifer = String.init(describing: self)
    
    override init(frame: CGRect) {
        self.textLabel = UILabel.init(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        self.textLabel.textAlignment = NSTextAlignment.center
        self.textLabel.font = UIFont.systemFont(ofSize: 14)
        super.init(frame: frame)
        self.addSubview(self.textLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textLabel.frame = self.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
