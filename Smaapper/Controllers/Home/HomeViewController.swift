//
//  HomeVC.swift
//  Smaapper
//
//  Created by Alessandro Comparini on 26/04/23.
//

import UIKit

class HomeVC: UIViewController {
    
    static let favoritesID = "Favorites"
    static let categoriesID = "Categories"
    
    enum StartFlow {
        case window
        case dock
    }
    private var activationWindowControl = false
    private var activationDockControl = false
    
    private let iconsDock = ["paperplane.fill",
                             "square.and.arrow.up.trianglebadge.exclamationmark",
                             "paintbrush.fill",
                             "die.face.5",
                             "pianokeys.inverse",
                             "fan.oscillation.fill",
                             "light.beacon.max.fill",
                             "door.left.hand.closed",
                             "eraser.fill",
                             "xmark.seal",
                             "scribble",
                             "bolt.horizontal" ]
    
    
    
    private let viewModel = HomeViewModel()
    private var categoriesVC: CategoriesViewController?
    
    private var adjustTrailingDock = NSLayoutConstraint()
    
    private var resultDropdownMenu: DropdownMenuData?
    private var categories: DropdownMenuData = []
    private var turnOnMenuButton = false
    private var indexSection = 0
    private var indexRow = 0
    private var rowTapped: (section: Int, row: Int) = (0,0)
    
    private var weather: WeatherViewController?
    
    lazy var homeScreen: HomeView = {
        let home = HomeView(frame: .zero)
        return home
    }()
    
   
    override func loadView() {
        print(#function, #fileID)
        view = homeScreen.view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function, #fileID)
        configDelegate()
        configDropdownMenu()
        configDock()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#function, #fileID)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(#function, #fileID)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print(#function, #fileID)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print(#function, #fileID)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    //  MARK: - Private Function Area
    
    private func configDropdownMenu() {
        fetchDropdownMenu()
        configRowsHeightOfDropdowMenu()
        homeScreen.dropdownMenu.isShow = false
    }
    
    private func configDock() {
        setConstraintAlignmentHorizontalDock()
        setDockAlignment()
    }
    
    private func setConstraintAlignmentHorizontalDock() {
        self.adjustTrailingDock = homeScreen.dock.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        adjustTrailingDock.isActive = true
    }
    
    private func configDelegate() {
        homeScreen.setDelegate(self)
        FloatWindowManager.instance.setDelegate(self)
        homeScreen.dock.setDelegate(self)
    }
    
    private func openCloseDropdownMenu() {
        homeScreen.dropdownMenu.isShow = !homeScreen.dropdownMenu.isShow
    }
    
    
    //  MARK: - Populate DropdowMenu
    
    private func fetchDropdownMenu() {
        viewModel.fetchDropdownMenu(.file) { result, error in
            if error != nil {
                print(#function, #file, error?.localizedDescription ?? "")
                return
            }
            if let result {
                self.resultDropdownMenu = result
                self.populateDropdownMenu()
            }
        }
    }
    
    private func configRowsHeightOfDropdowMenu() {
        guard let resultDropdownMenu else {return }
        let lastSection = resultDropdownMenu.count - 1
        _ = homeScreen.dropdownMenu.setSectionFooterHeight(forSection: lastSection, 1)
    }
    
    private func populateDropdownMenu() {
        guard let resultDropdownMenu else {return }
        resultDropdownMenu.enumerated().forEach { (index,sectionMenu) in
            self.indexSection = index
            let section = populateSection(sectionMenu.section)
            if let rows = sectionMenu.items {
                populateRowsOfSection(section, rows)
            }
        }
    }
    
    private func populateSection(_ sectionText: String? ) -> Section {
        let middleSectionView = homeScreen.createMiddleSectionView(sectionText ?? "")
        let section = Section(leftView: nil, middleView: middleSectionView)
        homeScreen.dropdownMenu.setSectionInDropdown(section)
        return section
    }
    
    private func populateRowsOfSection(_ section: Section, _ rows: [RowDropdownMenuData] ) {
        rows.enumerated().forEach { (index,row) in
            self.indexRow = index
            let row: Row = self.createRowView(row)
            homeScreen.dropdownMenu.setRowInSection(section, row)
        }
    }
    
    private func createRowView(_ row: RowDropdownMenuData) -> Row {
        let leftView = createLeftView(row.leftImage)
        let middleView = createMiddleView(row.title)
        let rightView = createRightView(row)
        return Row(leftView: leftView, middleView: middleView, rightView: rightView)
    }
    
    private func createLeftView(_ leftImage: String?) -> UIView? {
        guard let leftImage else { return nil }
        return homeScreen.createLeftRowView(leftImage)
    }
    
    private func createMiddleView(_ title: String?) -> UIView {
        guard let title else { return UIView() }
        return homeScreen.createMiddleRowView(title)
    }
    
    private func createRightView(_ row: RowDropdownMenuData) -> UIView? {
        if let subMenu = row.subMenu {
            return addChevronToSubMenu(subMenu)
        }
        guard let rightImage = row.rightImage else { return nil }
        return homeScreen.createRightRowView(rightImage, Theme.shared.currentTheme.onSurface)
    }
    
    private func addChevronToSubMenu(_ subMenu: DropdownMenuData ) -> UIView? {
        if !subMenu.isEmpty {
            return homeScreen.createRightRowView("chevron.forward", Theme.shared.currentTheme.onSurfaceVariant)
        }
        return nil
    }
    
    private func addHeartToFavorites() -> UIView? {
        guard let resultDropdownMenu else { return nil }
        if (resultDropdownMenu[self.indexSection].section == HomeVC.favoritesID) {
            return homeScreen.createRightRowView("heart.fill", Theme.shared.currentTheme.onSurface)
        }
        return nil
    }
    
    private func showCategoriesViewController(_ subMenu: DropdownMenuData) {
        categoriesVC = CategoriesViewController(subMenu)
        configCategoriesDelegate()
        if let categoriesVC {
            categoriesVC.modalPresentationStyle = .fullScreen
            present(categoriesVC, animated: true)
        }
    }
    
    private func configCategoriesDelegate() {
        if let categoriesVC {
            categoriesVC.delegate = self
        }
    }
    
    
    private func openCategories() {
        guard let resultDropdownMenu else {return}
        guard let items = resultDropdownMenu[rowTapped.section].items else { return }
        if items[rowTapped.row].title == HomeVC.categoriesID {
            self.categories = items[rowTapped.row].subMenu ?? []
            showCategoriesViewController(categories)
        }   
    }
    
    private func hideElementsForShowingFloatWindow() {
        homeScreen.clock.setOpacity(0.6)
        homeScreen.weather.setHidden(true)
        homeScreen.askChatGPTView.setHidden(true)
    }
    
    
    
    
//  MARK: - DOCK Area
    
    private func setDockAlignment() {
        print(#function, #fileID)
        if FloatWindowManager.instance.listWindows.count == 4 {
            self.adjustTrailingDock.constant = -50
        }

        if FloatWindowManager.instance.listWindows.count > 4 {
            self.adjustTrailingDock.constant = -90
        }
    }
    
    private func reloadDock() {
        print(#function, #fileID)
        setDockAlignment()
        homeScreen.dock.reload()
        configItemsMinimized()
    }
    
    private func configItemsMinimized() {
        print(#function, #fileID)
        FloatWindowManager.instance.listWindows.enumerated().forEach { (index,win) in
            if (win.isMinimized) {
                homeScreen.dock.getCellItem(index) { cellItem in
                    self.minimizeItemDock(cellItem)
                }
            }
        }



    }
    
    private func showDock() {
        print(#function, #fileID)
        if isShowDockIfOneWindow() {
            homeScreen.dock.isShow = true
            return
        }
        if isShowDockIfMoreThanOneWindow() {
            homeScreen.dock.isShow = true
            return
        }
        homeScreen.dock.isShow = false
    }
    
    
    private func isShowDockIfOneWindow() -> Bool {
        let countWindow = FloatWindowManager.instance.listWindows.count
        if (countWindow < 1) || (countWindow > 1)  {return false}
        
        if FloatWindowManager.instance.listWindows[0].isMinimized {
            return true
        }
        return false
    }
    
    private func isShowDockIfMoreThanOneWindow() -> Bool {
        if FloatWindowManager.instance.listWindows.count < 2 {return false}
        
        if FloatWindowManager.instance.listWindows.count > 1 {
            return true
        }
        
        return false
    }
    
    private func getIcon(_ index: Int) -> String {
        let win = FloatWindowManager.instance.listWindows[index]
        let category: (section:Int, row:Int) = win.customAttribute as! (section:Int, row:Int)
        let icon = self.categories[category.section].items?[category.row].leftImage ?? ""
        return icon
    }
    
    private func activationItemDock(_ activeWindow: FloatWindowViewController?) {
        print(#function, #fileID)
        if !homeScreen.dock.isShow { return }
        if let activeWindow {
            if let indexWin = FloatWindowManager.instance.getIndexById(activeWindow.id) {
                if indexWin != homeScreen.dock.view.activeItem {
                    homeScreen.dock.selectItem(indexWin, at: .centeredHorizontally)
                }
            }
        }
    }

    private func activationWindow(_ indexItem: Int?) {
        print(#function, #fileID)
        if let indexItem {
            FloatWindowManager.instance.activeWindow = FloatWindowManager.instance.listWindows[indexItem]
        }
    }
    
    private func restoreItemDock(_ cellItem: UIView) {
        print(#function, #fileID)
        UIView.animate(withDuration: 0.3) {
            cellItem.transform = CGAffineTransform.identity
        }
    }
    
    private func minimizeItemDock(_ cellItem: UIView) {
        print(#function, #fileID)
        UIView.animate(withDuration: 0.3) {
            cellItem.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
    }
    
        
}



//  MARK: - EXTENSION HomeViewDelegate

extension HomeVC: HomeViewDelegate {
    func openMenu() {
        self.homeScreen.turnOnMenuButton()
    }
    
    func closeMenu() {
        self.homeScreen.turnOffMenuButton()
    }
       
    func dropdownMenuTapped(_ rowTapped: (section: Int, row: Int)) {
        self.rowTapped = rowTapped
        openCategories()
    }
    
    func menuButtonTapped() {
        openCloseDropdownMenu()
    }
    
}


//  MARK: - EXTENSION HomeViewDelegate

extension HomeVC: CategoriesViewControllerDelegate {
    
    func selectedCategory(_ section: Int, _ row: Int) {
        print(#function, #fileID)
        openCloseDropdownMenu()
        addFloatWindow((section,row))
    }
    
    private func addFloatWindow(_ category: (section: Int, row: Int)) {
        print(#function, #fileID)
        let weather = WeatherViewController(frame: CGRect(x: 80, y: 350, width: 160, height: 250))
        weather.setCustomAttribute(category)
        hideElementsForShowingFloatWindow()
        weather.present(insideTo: homeScreen.viewFloatWindow.view)
    }
    
}



//  MARK: - EXTENSION FloatWindowManagerDelegate

extension HomeVC: FloatWindowManagerDelegate {
    func minimizedWindow(_ floatWindow: FloatWindowViewController) {
        if let index = FloatWindowManager.instance.getIndexById(floatWindow.id) {
            homeScreen.dock.getCellItem(index) { [weak self] cellItem in
                self?.minimizeItemDock(cellItem)
            }
        }
        showDock()
    }
    
    func restoredWindow(_ floatWindow: FloatWindowViewController) {
        print(#function, #fileID)
        if let index = FloatWindowManager.instance.getIndexById(floatWindow.id) {
            homeScreen.dock.getCellItem(index) { [weak self] cellItem in
                self?.restoreItemDock(cellItem)
            }
        }
        showDock()
    }
    
    func openWindow(_ floatWindow: FloatWindowViewController) {
        print(#function, #fileID)
        reloadDock()
        showDock()
    }
    
    func deactivatedWindow(_ deactiveWindow: FloatWindowViewController) {
        print(#function, #fileID)
        deactiveWindow.view.removeShadowByID("activeWindow")
        homeScreen.dock.deselectActiveItem()
    }
    
    func activatedWindow(_ activeWindow: FloatWindowViewController) {
        activeWindow.setShadow { build in
            build
                .setColor(Theme.shared.currentTheme.primary)
                .setOffset(width: 0, height: 0)
                .setOpacity(0.8)
                .setRadius(2)
                .setBringToFront()
                .setID("activeWindow")
                .apply()
        }
        activationItemDock(activeWindow)
    }

    func closeWindow(_ floatWindow: FloatWindowViewController) {
        reloadDock()
        showDock()
    }
    
    func allClosedWindows() {
        self.homeScreen.clock.setOpacity(1)
        self.homeScreen.weather.setHidden(false)
        self.homeScreen.askChatGPTView.setHidden(false)
    }
    
}



//  MARK: - EXTENSION DockDelegate
extension HomeVC: DockDelegate {
    func didSelectItemAt(_ indexItem: Int) {
        print(#function, #fileID)
        activationWindow(indexItem)
    }
    
    func activatedItemDock(_ indexItem: Int) {
        print(#function, #fileID)
        self.homeScreen.dock.getCellItem(indexItem) { cellItem in
            Shadow(cellItem.subviews[0].subviews[0])
                .setColor(Theme.shared.currentTheme.primary.adjustBrightness(20))
                .setOffset(width: 0, height: 0)
                .setOpacity(1)
                .setRadius(2)
                .setBringToFront()
                .setID("activeItemDock")
                .apply()
        }
        
    }
    
    func deactivatedItemDock(_ indexItem: Int) {
        print(#function, #fileID)
        self.homeScreen.dock.getCellItem(indexItem) { cellItem in
            cellItem.subviews[0].subviews[0].removeShadowByID("activeItemDock")
        }
        
    }
    
    func numberOfItemsCallback() -> Int {
        return FloatWindowManager.instance.listWindows.count
    }
    
    func cellItemCallback(_ indexItem: Int) -> UIView {
        let img = getIcon(indexItem)
        return homeScreen.createIconsDock(img)
    }
    

}
