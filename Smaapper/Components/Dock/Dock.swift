//
//  Dock.swift
//  Smaapper
//
//  Created by Alessandro Comparini on 16/05/23.
//

import UIKit

class Dock: View {
    
    typealias cellCallbackAlias = (_ indexItem: Int) -> UIView
    typealias numberOfItemsCallbackAlias = () -> Int
    
    private let numberOfItemsCallback: numberOfItemsCallbackAlias
    private let cellCallback: cellCallbackAlias
    private let hierarchy: CGFloat = 1100
    
    private var _isShow = false
    private var alreadyApplied = false
    private var dockViewBounds = CGRect()
    private var blurEnabled = false
    private var container = UIView()
    
    private let layout: UICollectionViewFlowLayout
    private var customConstraintWidthContainer: NSLayoutConstraint = NSLayoutConstraint()
    private var isUserInteractionEnabledItems = false
    
    private var customItemSize: [Int:CGSize] = [:]
    private var itemsSize = CGSize(width: 50, height: 50)
    private let marginContainer: CGFloat = 8

    private let collection: UICollectionView
    
    
    init(numberOfItemsCallback: @escaping () -> Int, cellCallback: @escaping cellCallbackAlias ) {
        self.numberOfItemsCallback = numberOfItemsCallback
        self.cellCallback = cellCallback
        self.layout = UICollectionViewFlowLayout()
        self.collection = UICollectionView(frame: .zero, collectionViewLayout: self.layout)
        super.init()
        self.initialization()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialization() {
        self.collection.backgroundColor = .clear
        self.layout.scrollDirection = .horizontal
        self.collection.setCollectionViewLayout(self.layout, animated: true)
        self.container.clipsToBounds = true
        self.setMinimumLineSpacing(10)
        self.setContentInset(top: 10, left: 10, bottom: 10, rigth: 10)
        self.setShowsHorizontalScrollIndicator(false)
        self.layer.zPosition = hierarchy
    }
    
    var content: UIView { self.collection}
    
    var isShow: Bool {
        get { return self._isShow}
        set {
            self._isShow = newValue
            applyOnceConfig()
            self.isHidden = !_isShow
        }
    }

    
//  MARK: - SET Properties

    
    @discardableResult
    func setSize(indexItem: Int, _ size: CGSize) -> Self {
        self.customItemSize.updateValue(size, forKey: indexItem)
        return self
    }
    
    @discardableResult
    func setSize(_ size: CGSize) -> Self {
        self.itemsSize = size
        return self
    }
    
    @discardableResult
    func setShowsHorizontalScrollIndicator(_ flag: Bool) -> Self {
        self.collection.showsHorizontalScrollIndicator = flag
        return self
    }
    
    @discardableResult
    func setContentInset(top: CGFloat, left: CGFloat, bottom: CGFloat, rigth: CGFloat) -> Self {
        self.collection.contentInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: rigth)
        return self
    }
    
    @discardableResult
    func setContentInsetAdjustmentBehavior(_ insetAdjustment: UIScrollView.ContentInsetAdjustmentBehavior ) -> Self {
        self.collection.contentInsetAdjustmentBehavior = insetAdjustment
        return self
    }
    
    @discardableResult
    func setMinimumLineSpacing(_ minimumSpacing: CGFloat) -> Self {
        self.layout.minimumLineSpacing = minimumSpacing
        return self
    }
    
    @discardableResult
    func setIsUserInteractionEnabledItems(_ isUserInteractionEnabled: Bool) -> Self {
        self.isUserInteractionEnabledItems = isUserInteractionEnabled
        return self
    }
    
    @discardableResult
    func setBlur(_ flag: Bool) -> Self {
        self.blurEnabled = flag
        return self
    }
    
    
//  MARK: - OVVERRIDE Base Component
    
    @discardableResult
    override func setBorder(_ border: (_ build: Border) -> Border) -> Self {
        _ = border(Border(self.container))
        return self
    }
   
    @discardableResult
    override func setNeumorphism(_ neumorphism: (_ build: Neumorphism) -> Neumorphism) -> Self {
        _ = neumorphism(Neumorphism(self.container))
        return self
    }
    
    @discardableResult
    override func setGradient(_ gradient: (_ build: Gradient) -> Gradient) -> Self {
        _ = gradient(Gradient(self.container))
        return self
    }
    
    @discardableResult
    override func setShadow(_ shadow: (_ build: Shadow) -> Shadow) -> Self {
        self.collection.makeShadow { make in
            make.setColor(.red)
                .setOffset(width: 10, height: 10)
                .apply()
        }
        return self
    }
    
    
//  MARK: - Private Function Area
    
    private func applyOnceConfig() {
        if self._isShow && !alreadyApplied {
            DispatchQueue.main.async {
                self.configDock()
                self.RegisterCell()
                self.setDelegate()
                self.alreadyApplied = true
            }
            
        }
    }
    
    private func RegisterCell() {
        self.collection.register(DockCell.self, forCellWithReuseIdentifier: DockCell.identifier)
    }
    
    private func setDelegate() {
        collection.delegate = self
        collection.dataSource = self
    }
    
    private func configDock() {
        applyBlur()
        addElementsInDock()
        configConstraints()
        
    }
    
    private func addElementsInDock() {
        container.add(insideTo: self)
        collection.add(insideTo: container)
    }
    
    
    private func configConstraints() {
        configConstraintsContainer()
        configConstraintsCollection()
        
    }
    
    private func configConstraintsContainer() {
        self.dockViewBounds = self.bounds
        customConstraintWidthContainer = self.container.widthAnchor.constraint(equalToConstant: 0)
        customConstraintWidthContainer.isActive = true
        container.makeConstraints { make in
            make
                .setTop.equalTo(self, .top)
                .setHorizontalAlignmentX.equalTo(self)
                .setHeight.equalTo(self)
        }
        configConstraintWidthCollection()
    }
    
    private func configConstraintsCollection() {
        self.collection.makeConstraints { make in
            make
                .setTop.setBottom.equalToSuperView
                .setLeading.setTrailing.equalToSuperView(marginContainer)
        }
    }
    
    private func configConstraintWidthCollection() {
        let sizeAllItems = self.calculateSizeAllItems()
        if sizeAllItems >= self.dockViewBounds.width {
            self.customConstraintWidthContainer.constant = self.dockViewBounds.width
        } else {
            self.customConstraintWidthContainer.constant = sizeAllItems
        }
    }
    
    private func calculateSizeAllItems() -> CGFloat {
        let spacing = calculateLineSpacing()
        let contentInset = calculateContentInset()
        let itemSize = calculateItemSize()
        return itemSize + spacing + contentInset + (marginContainer*2)
    }
    
    private func calculateLineSpacing() -> CGFloat {
        let numberOfItems = self.numberOfItemsCallback()
        if numberOfItems > 1 {
            return (numberOfItems.toCGFloat - 1) * layout.minimumLineSpacing
        }
        return 0.0
    }
    
    private func calculateContentInset() -> CGFloat {
        return self.collection.contentInset.left + self.collection.contentInset.right
    }
    
    private func calculateItemSize() -> CGFloat {
        let customItemSize = calculateCustomItemSize()
        let itemSize = calculateItemSizeExcludingCustomItemSize()
        return customItemSize + itemSize
    }
    
    private func calculateCustomItemSize() -> CGFloat {
        return self.customItemSize.reduce(0) { $0 + $1.value.width }
    }
    
    private func calculateItemSizeExcludingCustomItemSize() -> CGFloat {
        return (self.numberOfItemsCallback() - self.customItemSize.count).toCGFloat * itemsSize.width
    }
    
    
    private func applyBlur() {
        if !blurEnabled { return }
        container.makeBlur { make in
            make.setStyle(.dark)
                .apply()
        }
    }
    
}



//  MARK: - Extension Delegate Flow Layout
extension Dock: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.customItemSize[indexPath.row] ?? itemsSize
    }
    
}


//  MARK: - Extension Delegate
extension Dock: UICollectionViewDelegate {
    
}



//  MARK: - Extension DataSource
extension Dock: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfItemsCallback()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DockCell.identifier, for: indexPath) as! DockCell
        let item = self.cellCallback(indexPath.row)
        item.isUserInteractionEnabled = self.isUserInteractionEnabledItems
        cell.setupCell(item)
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

}


