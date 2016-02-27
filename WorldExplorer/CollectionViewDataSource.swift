//
//  Created by Pierluigi Cifani on 27/02/16.
//  Copyright © 2016 BlurSoftware. All rights reserved.
//

import Cocoa

public protocol ConfigurableCell {
    typealias T
    
    static var reuseIdentifier: String { get }
    static var nib: NSNib { get }

    func configureFor(viewModel viewModel: T) -> Void
}

extension ConfigurableCell where Self: NSCollectionViewItem {
    static var reuseIdentifier: String {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    static var nib: NSNib {
        return NSNib(nibNamed: reuseIdentifier, bundle: NSBundle.mainBundle())!
    }
}

///Represent the different states that the Collection View can be in
public enum DataSourceState<Model> {
    case Loading
    case Values([Model])
    case Error(ErrorType)
}

public class CollectionViewDataSource<Model, Cell: ConfigurableCell where Cell: NSCollectionViewItem> {
    
    /// This is neccesary since I couldn't figure out how to
    /// do it using just protocols, since they don't support generics
    /// and making the generics type of both ConfigurableCell and Model
    /// match impossible as of Swift 2.1
    public typealias ModelMapper = (Model) -> Cell.T
    
    public var state: DataSourceState<Model> = .Loading {
        didSet {
            switch self.state {
            case .Error(_):
                //TODO: Show an error!
                break
            case .Values(_):
                activityIndicator.hidden = true
                activityIndicator.stopAnimation(nil)
            case .Loading:
                activityIndicator.hidden = false
                activityIndicator.startAnimation(nil)
            }

            self.collectionView?.reloadData()
        }
    }
    
    public weak var collectionView: NSCollectionView?
    public let collectionViewFlowLayout: NSCollectionViewFlowLayout
    public let mapper: ModelMapper
    var activityIndicator: NSProgressIndicator = {
        let indicator = NSProgressIndicator()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.style = .SpinningStyle
        indicator.hidden = true
        return indicator
    }()
    
    public init(collectionView: NSCollectionView,
        mapper: ModelMapper,
        collectionViewFlowLayout: NSCollectionViewFlowLayout = WrappedLayout()) {
            self.mapper = mapper
            self.collectionView = collectionView
            self.collectionViewFlowLayout = collectionViewFlowLayout
            
            collectionView.addSubview(activityIndicator)
            let xCenterConstraint = NSLayoutConstraint(item: activityIndicator, attribute: .CenterX, relatedBy: .Equal, toItem: collectionView, attribute: .CenterX, multiplier: 1, constant: 0)
            collectionView.addConstraint(xCenterConstraint)
            let yCenterConstraint = NSLayoutConstraint(item: activityIndicator, attribute: .CenterY, relatedBy: .Equal, toItem: collectionView, attribute: .CenterY, multiplier: 1, constant: 0)
            collectionView.addConstraint(yCenterConstraint)

            collectionView.registerNib(Cell.nib, forItemWithIdentifier: Cell.reuseIdentifier)
            collectionView.collectionViewLayout = WrappedLayout()
            collectionView.dataSource = bridgedDataSource
            collectionView.delegate = bridgedDataSource
    }
    
    private lazy var bridgedDataSource: BridgedCollectionViewDataSource = BridgedCollectionViewDataSource(
        numberOfItemsInSection: { [weak self] (section) in
            guard let strongSelf = self else { return 0 }
            switch strongSelf.state {
            case .Loading:
                return 0
            case .Error(_):
                return 0
            case .Values(let values):
                return values.count
            }
        },
        itemForRowAtIndexPath: { [weak self] (collectionView, indexPath) -> NSCollectionViewItem in
            guard let strongSelf = self else { return NSCollectionViewItem() }
            
            let optionalViewModel: Cell.T? = {
                switch strongSelf.state {
                case .Loading:
                    return nil
                case .Error(_):
                    return nil
                case .Values(let values):
                    return strongSelf.mapper(values[indexPath.item])
                }
            }()
            
            guard let viewModel = optionalViewModel else { return NSCollectionViewItem() }
           
            let reuseIdentifier = Cell.reuseIdentifier
            let collectionItem = collectionView.makeItemWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! Cell
            collectionItem.configureFor(viewModel: viewModel)
            return collectionItem
        },
        itemTappedAtIndexPath: { (indexPath) -> Void in
        
        }
    )
}

/*
Avoid making CollectionViewDataSource inherit from NSObject.
Keep classes pure Swift.
Keep responsibilies focused.
*/

@objc private final class BridgedCollectionViewDataSource: NSObject, NSCollectionViewDataSource, NSCollectionViewDelegate {
    
    typealias NumberOfItemsInSectionHandler = (Int) -> Int
    typealias ItemForRowAtIndexPathHandler = (NSCollectionView, NSIndexPath) -> NSCollectionViewItem
    typealias ItemTappedHandler = (NSIndexPath) -> Void
    
    let numberOfItemsInSection: NumberOfItemsInSectionHandler
    let itemForRowAtIndexPath: ItemForRowAtIndexPathHandler
    let itemTappedAtIndexPath: ItemTappedHandler
    
    init(numberOfItemsInSection: NumberOfItemsInSectionHandler,
        itemForRowAtIndexPath: ItemForRowAtIndexPathHandler,
        itemTappedAtIndexPath: ItemTappedHandler) {
            
            self.numberOfItemsInSection = numberOfItemsInSection
            self.itemForRowAtIndexPath = itemForRowAtIndexPath
            self.itemTappedAtIndexPath = itemTappedAtIndexPath
    }

    @objc func collectionView(collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItemsInSection(section)
    }
    
    @objc func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath indexPath: NSIndexPath) -> NSCollectionViewItem {
        return itemForRowAtIndexPath(collectionView, indexPath)
    }
    
    @objc func collectionView(collectionView: NSCollectionView, didSelectItemsAtIndexPaths indexPaths: Set<NSIndexPath>) {
    
    }
}

class WrappedLayout: NSCollectionViewFlowLayout {
    override init() {
        super.init()
        self.itemSize = NSMakeSize(100, 50)
        self.minimumInteritemSpacing = 10.0
        self.minimumLineSpacing = 10.0
        self.sectionInset = NSEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> NSCollectionViewLayoutAttributes? {
        let attributes = super.layoutAttributesForItemAtIndexPath(indexPath)
        attributes?.zIndex = indexPath.item
        return attributes
    }

    override func layoutAttributesForElementsInRect(rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        let layoutAttributesArray = super.layoutAttributesForElementsInRect(rect)
        layoutAttributesArray.forEach {
            guard let item = $0.indexPath?.item else {return}
            $0.zIndex = item
        }
        
        return layoutAttributesArray
    }
}
