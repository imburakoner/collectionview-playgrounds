import UIKit
import XCPlayground

/**
 
 # Playground of Justice
 
 */

struct Event {
    var height: CGFloat
    var color: UIColor
}

// Predictability is a good thing yo
srand(123)

func randomHeight() -> CGFloat {
    return CGFloat((rand() % 100) + 50)
}

let colors = [
    UIColor.redColor(),
    UIColor.greenColor(),
    UIColor.blueColor()
]


func randomColor() -> UIColor {
    let index = Int(rand() % 3)
    return colors[index]
}

class TestLayout: UICollectionViewFlowLayout {
    let verticalPadding: CGFloat = 10.0
    
    override func collectionViewContentSize() -> CGSize {
        guard let collectionView = collectionView,
            let dataSource: TestDataSource = collectionView.dataSource as? TestDataSource else { return CGSizeZero }
        var maxY: CGFloat = 0.0
        (0..<dataSource.events.count).forEach { index in
            let originY = dataSource.cellOrigins[index].y
            let height = dataSource.cellSizes[index].height
            let newMax = originY + height
            if newMax > maxY {
                maxY = newMax
            }
        }
        let size = CGSize(width: collectionView.frame.width, height: maxY + 10)
        return size
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView,
            let dataSource = collectionView.dataSource as? TestDataSource else { return [] }

        let trueRect = CGRectInset(rect, 0, -100)
        let paths = indexPaths(trueRect)
        
        return paths.map { path in
            let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: path)
            let size = dataSource.cellSizes[path.item]
            let origin = dataSource.cellOrigins[path.item]
            attributes.size = size
            attributes.frame = CGRect(origin: origin, size: size)

            return attributes
        }
    }
    
    func firstIndexPath(rect: CGRect) -> NSIndexPath {
        guard let dataSource = collectionView?.dataSource as? TestDataSource else { return NSIndexPath(forItem: 0, inSection: 0) }
        
        for (index, origin) in dataSource.cellOrigins.enumerate() {
            if origin.y >= CGRectGetMinY(rect) {
                return NSIndexPath(forItem: index, inSection: 0)
            }
        }
        
        return NSIndexPath(forItem: 0, inSection: 0)
    }
    
    func lastIndexPath(rect: CGRect) -> NSIndexPath {
        guard let dataSource = collectionView?.dataSource as? TestDataSource else { return NSIndexPath(forItem: 0, inSection: 0) }
        
        for (index, origin) in dataSource.cellOrigins.enumerate() {
            if origin.y >= CGRectGetMaxY(rect) {
                return NSIndexPath(forItem: index, inSection: 0)
            }
        }
        
        return NSIndexPath(forItem: dataSource.events.count - 1, inSection: 0)
    }
    
    func indexPaths(rect: CGRect) -> [NSIndexPath] {
        let min = firstIndexPath(rect).item
        let max = lastIndexPath(rect).item
        
        return (min...max).map { return NSIndexPath(forItem: $0, inSection: 0) }
    }
    
}

class TestDataSource: NSObject, UICollectionViewDataSource {
    var events = (0..<100).map {_ in
        return Event(
            height: randomHeight(),
            color: randomColor()
        )
    }
    
    let cellOrigins: [CGPoint]
    let cellSizes: [CGSize]
    
    override init() {
        var tempOrigins = [CGPoint]()
        var tempSizes = [CGSize]()
        var leftHeight: CGFloat = 0.0
        var rightHeight: CGFloat = 0.0
        let padding: CGFloat = 10.0
        events.forEach { event in
            var x: CGFloat = 0
            var y: CGFloat = 0.0
            let width: CGFloat = 100.0
            let height: CGFloat = event.height
            
            if rightHeight > leftHeight {
                x = 0
                y = leftHeight
                leftHeight += event.height + padding
            } else {
                x = 110
                y = rightHeight
                rightHeight += event.height + padding
            }
            
            tempOrigins.append(CGPoint(x: x, y: y))
            tempSizes.append(CGSize(width: width, height: height))
        }
        
        cellOrigins = tempOrigins
        cellSizes = tempSizes
        
        super.init()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! TestCell
        let event = events[indexPath.item]
        cell.backgroundColor = event.color
        return cell
    }
}

class TestCell: UICollectionViewCell {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}

let dataSource = TestDataSource()
let layout = TestLayout()
layout.scrollDirection = .Vertical

let foo = UICollectionViewController(collectionViewLayout: layout)
foo.collectionView?.dataSource = dataSource
foo.collectionView?.registerClass(TestCell.self, forCellWithReuseIdentifier: "cell")
foo.collectionView?.backgroundColor = UIColor.whiteColor()

XCPlaygroundPage.currentPage.liveView = foo

