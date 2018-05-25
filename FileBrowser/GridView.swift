//
//  GridView.swift
//  FileBrowser
//
//  Created by yongjie_zou on 2018/5/23.
//

import UIKit

protocol GridViewDelegate: NSObjectProtocol {
    func numberOfColumns() -> Int
    func numberOfLines() -> Int
    func widthOfColumn(column: Int) -> CGFloat
    func heightOfLine(line: Int) -> CGFloat
    func cellForGridView(_ gridView:GridView, column:Int, line:Int) -> UICollectionViewCell
    func gridView(_ gridView:GridView, didSelectCell atColumn:Int, line:Int) -> Void
}

class GridView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    let scrollView: UIScrollView
    let layout: GridLayout
    let collectionView: UICollectionView
    var delegate:GridViewDelegate? {
        didSet {
            guard let delegate = delegate else {
                return
            }
            var widthOfColums = [CGFloat]()
            var heightOfLine = [CGFloat]()
            for index in 0..<delegate.numberOfColumns() {
                widthOfColums.append(delegate.widthOfColumn(column: index))
            }
            for index in 0..<delegate.numberOfLines() {
                heightOfLine.append(delegate.heightOfLine(line: index))
            }
            layout.widthOfColums = widthOfColums
            layout.heightOfLine = heightOfLine
        }
    }
    var numberOfColumns = 0
    var numberOfLines = 0

    override init(frame: CGRect) {
        self.scrollView = UIScrollView.init(frame: frame)
        
        layout = GridLayout.init()
        self.collectionView = UICollectionView.init(frame: frame, collectionViewLayout: layout)
        self.collectionView.register(GridCell.self, forCellWithReuseIdentifier: GridCell.reuseIdentifer)
        self.collectionView.backgroundColor = UIColor.clear
        self.collectionView.bounces = true
        super.init(frame: frame)
        self.addSubview(self.collectionView)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reload(line:Int) -> Void {

//        layout.heightOfLine[line] = (delegate?.heightOfLine(line: line))!
//        self.collectionView.reloadSections(test)
//        self.collectionView.reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.scrollView.frame = self.bounds
        self.collectionView.frame = self.bounds
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let delegate = delegate else {
            return 0
        }
        return delegate.numberOfLines()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let delegate = delegate else {
            return 0
        }
        return delegate.numberOfColumns()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let delegate = delegate else {
            return UICollectionViewCell.init()
        }
        return delegate.cellForGridView(self, column: indexPath.row, line: indexPath.section)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let delegate = delegate else {
            return
        }
        return delegate.gridView(self, didSelectCell: indexPath.row, line: indexPath.section)
    }
}

class GridCell: UICollectionViewCell {
    let textLabel: UILabel
    static let reuseIdentifer = String.init(describing: self)

    override init(frame: CGRect) {
        self.textLabel = UILabel.init(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        super.init(frame: frame)
        self.addSubview(self.textLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GridLayout: UICollectionViewLayout {
    var numberOfColumns = 0
    var numberOfLines = 0
    var widthOfColums = [CGFloat]()
    var heightOfLine = [CGFloat]()

    var itemAttributes = [[UICollectionViewLayoutAttributes]]()
    var contentSize = CGSize.zero

    override func prepare() {
        guard let collectionView = collectionView else {
            return
        }
        numberOfColumns = collectionView.numberOfItems(inSection: 0)
        numberOfLines = collectionView.numberOfSections
        
        //TODO:: operate add、delete
//        if itemAttributes.count != numberOfLines && widthOfColums.count == numberOfColumns && heightOfLine.count == numberOfLines {
        itemAttributes = [[UICollectionViewLayoutAttributes]]()
            generateItemAttributes()
//        }
    }

    override var collectionViewContentSize: CGSize {
        return contentSize
//        return CGSize.init(width: 2000, height: 3000)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let start = CACurrentMediaTime()
        
        var tempAttributes = [UICollectionViewLayoutAttributes]()
        var startColumn = 0
        var startLine = 0
        var endColumn = numberOfColumns - 1
        var endLine = numberOfLines - 1
        
        let startPoint = rect.origin
        let endPoint = CGPoint(x: startPoint.x + rect.size.width, y: startPoint.y + rect.size.height)
        for index in 0..<itemAttributes.first!.count {
            let attributes = itemAttributes.first![index]
            if (attributes.frame.origin.x <= startPoint.x && (attributes.frame.origin.x + attributes.frame.size.width) >= startPoint.x) {
                startColumn = index
                break
            }
        }
        for index in startColumn..<itemAttributes.first!.count {
            let attributes = itemAttributes.first![index]
            if (attributes.frame.origin.x <= endPoint.x && (attributes.frame.origin.x + attributes.frame.size.width) >= endPoint.x) {
                endColumn = index
                break
            }
        }
        for index in 0..<itemAttributes.count {
            let attributes = itemAttributes[index].first!
            if (attributes.frame.origin.y <= startPoint.y && (attributes.frame.origin.y + attributes.frame.size.height) >= startPoint.y) {
                startLine = index
                break
            }
        }
        for index in startLine..<itemAttributes.count {
            let attributes = itemAttributes[index].first!
            if (attributes.frame.origin.y <= endPoint.y && (attributes.frame.origin.y + attributes.frame.size.height) >= endPoint.y) {
                endLine = index
                break
            }
        }
        for column in startColumn...endColumn {
            for line in startLine...endLine {
                tempAttributes.append(itemAttributes[line][column])
            }
        }
        
        for attributes in itemAttributes.first! {
            guard let collectionView = collectionView else {
                break
            }
            
            var frame = attributes.frame
            var yOffset:CGFloat
            if #available(iOS 11.0, *) {
                yOffset = collectionView.adjustedContentInset.top
            } else {
                yOffset = collectionView.contentInset.top
            }
            frame.origin.y = collectionView.contentOffset.y + yOffset
            attributes.frame = frame
            
            //第一行都加入显示 ？？重复加入attributes有没有副作用呢？？
            tempAttributes.append(attributes)
        }
//        print("y--"+"\(itemAttributes.first!.first!.frame.origin.y)"+"  offsetY---"+"\(collectionView!.contentOffset.y)" + "   inset---" + "\(collectionView!.contentInset)")
        for index in 0..<itemAttributes.count {
            let attributes = itemAttributes[index].first!
            var frame = attributes.frame
            frame.origin.x = collectionView!.contentOffset.x
            attributes.frame = frame
            
            //第一列都加入显示
            tempAttributes.append(attributes)
        }
        
        let end = CACurrentMediaTime()
        print("execution time:" + String(format: "%f", end - start))
        
        return tempAttributes
        
//        for sectionAttributes in itemAttributes {
//            let filteredArray = sectionAttributes.filter { (attributes) -> Bool in
//                return rect.intersects(attributes.frame)
//            }
//            tempAttributes.append(contentsOf: filteredArray)
//        }
//        let end = CACurrentMediaTime()
//        print("execution time:" + String(format: "%f", end - start))
//        return tempAttributes
    }

    func generateItemAttributes() {
        var frame = CGRect(x: 0, y: 0, width: widthOfColums.first!, height: heightOfLine.first!)
        for section in 0..<numberOfLines {
            var sectionAttributes = [UICollectionViewLayoutAttributes]()
            
            for index in 0..<numberOfColumns {
                let indexPath = IndexPath(row: index, section: section)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                frame.size.width = widthOfColums[index]
                attributes.frame = frame
                sectionAttributes.append(attributes)
                frame.origin.x += widthOfColums[index]
                
                if section == 0 || index == 0 {
                    attributes.zIndex = 1023
                }
            }
            frame.origin.x = 0
            frame.origin.y += heightOfLine[section]
            itemAttributes.append(sectionAttributes)
        }
        
        if let attributes = itemAttributes.first?.first {
            attributes.zIndex = 1024
        }
        if let attributes = itemAttributes.last?.last {
            contentSize = CGSize(width: attributes.frame.maxX, height: attributes.frame.maxY)
        }
    }
}
