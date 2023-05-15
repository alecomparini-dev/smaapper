//
//  List.swift
//  Smaapper
//
//  Created by Alessandro Comparini on 04/05/23.
//

import UIKit


class List: UITableView {

    typealias didSelectRow = ((_ rowTapped: (section: Int, row: Int)) -> Void)

    private var alreadyApplied = false
    private var _isShow = false
    private var customSectionHeaderHeight: [Int : CGFloat] = [:]
    private var customSectionFooterHeight: [Int : CGFloat] = [:]
//    private var customSectionHeaderHeight: [Int : CGFloat] = [:]
    
    private var didSelectRow: didSelectRow?
    private var sections = [Section]()
    
    
    init(_ style: UITableView.Style) {
        super.init(frame: .zero, style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
//  MARK: - SET Properties
    @discardableResult
    func setRowHeight(_ height: CGFloat) -> Self {
        self.rowHeight = height
        return self
    }
    
    @discardableResult
    func setSectionHeaderHeight(_ height: CGFloat) -> Self {
        self.sectionHeaderHeight = height
        return self
    }
    
    @discardableResult
    func setSectionHeaderHeight(forSection: Int, _ height: CGFloat) -> Self {
        self.customSectionHeaderHeight.updateValue(height, forKey: forSection)
        return self
    }
    
    @discardableResult
    func setSectionFooterHeight(_ height: CGFloat) -> Self {
        self.sectionFooterHeight = height
        return self
    }
    
    @discardableResult
    func setSectionFooterHeight(forSection: Int, _ height: CGFloat) -> Self {
        self.customSectionFooterHeight.updateValue(height, forKey: forSection)
        return self
    }
    
    @discardableResult
    func setSeparatorStyle(_ style: UITableViewCell.SeparatorStyle) -> Self {
        self.separatorStyle = style
        return self
    }
    
    @discardableResult
    func setShowsVerticalScrollIndicator(_ flag: Bool) -> Self {
        self.showsVerticalScrollIndicator = flag
        return self
    }
    
    @discardableResult
    func setIsScrollEnabled(_ flag: Bool) -> Self {
        self.isScrollEnabled = flag
        return self
    }
    
    @discardableResult
    func setPadding(top: CGFloat , left: CGFloat, bottom: CGFloat, right: CGFloat) -> Self {
        self.contentInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        return self
    }
    
    @discardableResult
    func setDidSelectRow(_ closure: @escaping didSelectRow) -> Self {
        self.didSelectRow = closure
        return self
    }
    
    func setSectionInList(_ section: Section) {
        self.sections.append(section)
    }
    
    func setRowInSection(section: Section, leftView: UIView?, middleView: UIView, rightView: UIView?) {
        let row = Row(leftView: leftView, middleView: middleView, rightView: rightView)
        section.rows.append(row)
    }
    
    func setRowInSection(_ section: Section, _ row: Row) {
        section.rows.append(row)
    }
    
    
//  MARK: - Show List
    
    var isShow: Bool {
        get { return self._isShow }
        set {
            self._isShow = newValue
            applyOnceConfig()
            self.isHidden = !self._isShow
        }
    }
    
    func show() {
        applyOnceConfig()
        self.isHidden = false
    }

    func hide() {
        self.isHidden = true
    }
    
//  MARK: - Private Function Area
    
    private func applyOnceConfig() {
        if self._isShow && !alreadyApplied {
            self.RegisterCell()
            self.setDelegate()
            alreadyApplied = true
        }
    }
    
    private func RegisterCell() {
        self.register(ListCell.self, forCellReuseIdentifier: ListCell.identifier)
    }
    
    private func setDelegate() {
        delegate = self
        dataSource = self
    }

}

//  MARK: - Extension Delegate

extension List: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.customSectionHeaderHeight[section] ?? self.sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.customSectionFooterHeight[section] ?? self.sectionFooterHeight
    }
    
    
    private func isSectionEmpty(_ section: Section) -> Bool {
        if section.leftView == nil &&
            section.middleView == nil &&
            section.rightView == nil {
            return true
        }
        return false
    }
    
    private func isLastSection(_ section: Int) -> Bool {
        return sections.count == section + 1
    }
    

}

//  MARK: - Extension Data Source

extension List: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = ListCell()
        cell.setupCell(self.sections[section].leftView,
                       self.sections[section].middleView,
                       self.sections[section].rightView)
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListCell.identifier, for: indexPath) as! ListCell
        cell.setupCell(
            self.sections[indexPath.section].rows[indexPath.row].leftView,
            self.sections[indexPath.section].rows[indexPath.row].middleView,
            self.sections[indexPath.section].rows[indexPath.row].rightView
        )
        return cell 
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let didSelectRow = self.didSelectRow {
            didSelectRow((indexPath.section, indexPath.row))
        }
    }
    

    
}


