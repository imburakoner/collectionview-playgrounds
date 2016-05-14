import UIKit
import XCPlayground

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
        if let originY = dataSource.cellOrigins.last?.y, let height = dataSource.events.last?.height {
            let size = CGSize(width: collectionView.frame.width, height: originY + height + 10)
            return size
        }

        return CGSizeZero
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView,
              let dataSource = collectionView.dataSource as? TestDataSource else { return [] }

        let trueRect = CGRectInset(rect, 0, -150)
        
        var accumulativeOriginY = CGRectGetMinY(trueRect)
        let paths = indexPaths(trueRect)
        let width = CGRectGetWidth(collectionView.frame)
        
        return paths.map { path in
            let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: path)
            let event = dataSource.events[path.item]
            let size = CGSize(width: width, height: event.height)
            let origin = dataSource.cellOrigins[path.item]
            attributes.size = size
            attributes.frame = CGRect(origin: origin, size: size)
            accumulativeOriginY += event.height + verticalPadding
            
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
    
    override init() {
        var runningHeight: CGFloat = 0.0
        let padding: CGFloat = 10.0
        cellOrigins = events.map { event in
            let x: CGFloat = 0
            let y: CGFloat = runningHeight
            
            runningHeight += event.height + padding
            return CGPoint(x: x, y: y)
        }
        
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

