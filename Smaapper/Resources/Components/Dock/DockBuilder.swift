//
//  DockBuilder.swift
//  Smaapper
//
//  Created by Alessandro Comparini on 24/05/23.
//

import UIKit

class DockBuilder: BaseBuilder {
    
    private var dockViewBounds = CGRect()
    private var customConstraintWidthContainer: NSLayoutConstraint = NSLayoutConstraint()
    private var _isShow = false
    private var alreadyApplied = false
    
    private var dock: Dock
    var view: Dock { self.dock }
    
    init() {
        self.dock = Dock()
        super.init(self.dock)
        self.initialization()
    }
    
    private func initialization() {
        initiateContainer()
        initiateLayout()
        initiateCollection()
        setHierarchyVisualization()
        setDefault()
    }
    
//  MARK: - GET Properties
    func getCellItem(_ indexItem: Int, closure: @escaping Dock.closureGetCellItemAlias ) {
        let indexPath = IndexPath(row: indexItem, section: 0)
        if let cell = dock.collection.cellForItem(at: indexPath) {
            return closure(cell)
        }
        dock.setClosureGetCellItem(indexItem, closure: closure)
    }
    
//  MARK: - SET Properties
    
    @discardableResult
    func setSize(indexItem: Int, _ size: CGSize) -> Self {
        dock.customItemSize.updateValue(size, forKey: indexItem)
        return self
    }
    
    @discardableResult
    func setSize(_ size: CGSize) -> Self {
        dock.itemsSize = size
        return self
    }
    
    @discardableResult
    func setShowsHorizontalScrollIndicator(_ flag: Bool) -> Self {
        dock.collection.showsHorizontalScrollIndicator = flag
        return self
    }
    
    @discardableResult
    func setContentInset(top: CGFloat, left: CGFloat, bottom: CGFloat, rigth: CGFloat) -> Self {
        dock.collection.contentInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: rigth)
        return self
    }
    
    @discardableResult
    func setContentInsetAdjustmentBehavior(_ insetAdjustment: UIScrollView.ContentInsetAdjustmentBehavior ) -> Self {
        dock.collection.contentInsetAdjustmentBehavior = insetAdjustment
        return self
    }
    
    @discardableResult
    func setMinimumLineSpacing(_ minimumSpacing: CGFloat) -> Self {
        dock.layout.minimumLineSpacing = minimumSpacing
        return self
    }
    
    @discardableResult
    func setIsUserInteractionEnabledItems(_ isUserInteractionEnabled: Bool) -> Self {
        dock.isUserInteractionEnabledItems = isUserInteractionEnabled
        return self
    }
    
    @discardableResult
    func setBlur(_ flag: Bool, _ opacity: CGFloat = 1) -> Self {
        dock.blurEnabled = flag
        dock.opacity = opacity
        return self
    }
    
    override func setBorder(_ build: (BorderBuilder) -> BorderBuilder) -> Self {
        _ = build(BorderBuilder(dock.container))
        return self
    }
    
    
//  MARK: - SET Actions
    func reload() {
        dock.collection.reloadData()
        autoResizingContainer()
    }
    
    func selectItem(_ indexItem: Int, at: UICollectionView.ScrollPosition) {
        if self.isShow {
            let indexPath = IndexPath(row: indexItem, section: 0)
            dock.collection.selectItem(at: indexPath, animated: true, scrollPosition: at)
            dock.activeItem = indexItem
        }
    }
    
    func deselectActiveItem() {
        if self.isShow {
            if let activeItem = dock.activeItem {
                let indexPath = IndexPath(row: activeItem, section: 0)
                dock.collection.deselectItem(at: indexPath, animated: true)
                dock.activeItem = nil
            }
        }
    }
    
    
//  MARK: - SET Delegate
    func setDelegate(_ dockDelegate: DockDelegate) {
        self.dock.delegate = dockDelegate
    }
    
    
//  MARK: - SHOW Dock
    var isShow: Bool {
        get { return self._isShow}
        set {
            self._isShow = newValue
            applyOnceConfig()
            dock.isHidden = !_isShow
        }
    }
    
    
//  MARK: - Private Function Area
    
    private func applyOnceConfig() {
        if self._isShow && !alreadyApplied {
            RegisterCell()
            setDelegate()
            applyBlur()
            addElementsInDock()
            DispatchQueue.main.async { [weak self] in
                self?.configConstraints()
                self?.alreadyApplied = true
            }
        }
    }
    
    private func RegisterCell() {
        dock.collection.register(DockCell.self, forCellWithReuseIdentifier: DockCell.identifier)
    }
    
    private func setDelegate() {
        dock.collection.delegate = dock
        dock.collection.dataSource = dock
    }
    
    private func addElementsInDock() {
        dock.container.add(insideTo: dock)
        dock.collection.add(insideTo: dock.container)
    }
    
    private func configConstraints() {
        self.configConstraintsContainer()
        self.configConstraintsCollection()
    }
    
    private func configConstraintsContainer() {
        initializeWidthConstraintContainer()
        applyConstraintContainer()
        autoResizingContainer()
    }
    
    private func setDockBounds() {
        self.dockViewBounds = dock.bounds
    }
    
    private func initializeWidthConstraintContainer() {
        customConstraintWidthContainer = dock.container.widthAnchor.constraint(equalToConstant: 0)
        customConstraintWidthContainer.isActive = true
    }
    
    private func applyConstraintContainer() {
        dock.container.makeConstraints { make in
            make
                .setTop.equalTo(dock, .top)
                .setHorizontalAlignmentX.equalTo(dock)
                .setHeight.equalTo(dock)
        }
    }
    
    private func configConstraintsCollection() {
        dock.collection.makeConstraints { make in
            make
                .setTop.setBottom.equalToSuperView
                .setLeading.setTrailing.equalToSuperView(dock.marginContainer)
        }
    }
    
    private func autoResizingContainer() {
        setDockBounds()
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
        return itemSize + spacing + contentInset + (dock.marginContainer*2)
    }
    
    private func calculateLineSpacing() -> CGFloat {
        let numberOfItems = dock.delegate?.numberOfItemsCallback() ?? 0
        if numberOfItems > 1 {
            return (numberOfItems.toCGFloat - 1) * (dock.layout.minimumLineSpacing)
        }
        return 0.0
    }
    
    private func calculateContentInset() -> CGFloat {
        return (dock.collection.contentInset.left) + (dock.collection.contentInset.right)
    }
    
    private func calculateItemSize() -> CGFloat {
        let customItemSize = calculateCustomItemSize()
        let itemSize = calculateItemSizeExcludingCustomItemSize()
        return customItemSize + itemSize
    }
    
    private func calculateCustomItemSize() -> CGFloat {
        return dock.customItemSize.reduce(0) { $0 + $1.value.width }
    }
    
    private func calculateItemSizeExcludingCustomItemSize() -> CGFloat {
        return ((dock.delegate?.numberOfItemsCallback() ?? 0) - (dock.customItemSize.count)).toCGFloat * (dock.itemsSize.width)
    }
    
    private func applyBlur() {
        if !dock.blurEnabled { return }
        dock.container.makeBlur { make in
            make
                .setStyle(.dark)
                .setOpacity(dock.opacity)
                .apply()
        }
    }
    
    private func initiateCollection() {
        dock.collection.setCollectionViewLayout(self.dock.layout, animated: true)
        dock.collection.backgroundColor = .clear
        DispatchQueue.main.async { [weak self] in
            guard let self else {return}
            self.dock.collection.layer.cornerRadius = self.dock.layer.cornerRadius
            self.dock.collection.layer.maskedCorners = self.dock.layer.maskedCorners
        }
    }
    
    private func initiateContainer() {        
        self.dock.container.clipsToBounds = true
        self.dock.container.layer.cornerRadius = dock.layer.cornerRadius
        self.dock.container.layer.maskedCorners = dock.layer.maskedCorners
    }
    
    private func initiateLayout() {
        dock.layout.scrollDirection = .horizontal
    }
    
    private func setDefault() {
        self.setMinimumLineSpacing(10)
        self.setContentInset(top: 10, left: 10, bottom: 10, rigth: 10)
        self.setShowsHorizontalScrollIndicator(false)
    }
    
    private func setHierarchyVisualization() {
        dock.layer.zPosition = dock.hierarchy
    }

    
}




