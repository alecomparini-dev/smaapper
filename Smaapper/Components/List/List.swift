//
//  List.swift
//  Smaapper
//
//  Created by Alessandro Comparini on 04/05/23.
//

import UIKit

class List: UITableView {

    init() {
        super.init(frame: .zero, style: .plain)
        self.initialization()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialization() {
        self.RegisterCell()
        self.setDelegate()
    }
    
    
//  MARK: - SET Properties
    
    func setRowHeight(_ height: CGFloat) -> Self {
        self.rowHeight = height
        return self
    }
    
    func setSeparatorStyle(_ style: UITableViewCell.SeparatorStyle) -> Self {
        self.separatorStyle = style
        return self
    }
    
    func setShowsVerticalScrollIndicator(_ flag: Bool) -> Self {
        self.showsVerticalScrollIndicator = flag
        return self
    }
    
    func setIsScrollEnabled(_ flag: Bool) -> Self {
        self.isScrollEnabled = flag
        return self
    }
    
    func setPadding(top: CGFloat , left: CGFloat, bottom: CGFloat, right: CGFloat) -> Self {
        self.contentInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        return self
    }
    
    

    
//  MARK: - Private Function Area
    
    private func RegisterCell() {
        self.register(ListCell.self, forCellReuseIdentifier: ListCell.identifier)
    }
    
    private func setDelegate() {
        delegate = self
        dataSource = self
    }
    
    
}

extension List: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
}

extension List: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ListCell.identifier, for: indexPath) as! ListCell
        
        let img = ImageView()
            .setImage(UIImage(systemName: "person"))
            .setContentMode(.center)
            .setSize(18)
            .setTintColor(.white)
            .setBorder { build in
                build.setColor(.yellow)
                    .setWidth(0)
            }
            .setOnTap { imageView in
                print("caralhoooo - \(indexPath.row + 1)")
            }
            
        
        let label = Label("Categorias")
            .setColor(.white)
            .setFont(UIFont.systemFont(ofSize: 17, weight: .regular))
            .setTextAlignment(.left)
        
        let imgRight = ImageView()
            .setImage(UIImage(systemName: "chevron.forward"))
            .setContentMode(.center)
            .setSize(12)
            .setTintColor(.white)
            .setOnTap { imageView in
                print("eh pra direita caralhooo - \(indexPath.row + 1)")
            }
        
        let listCellModel = ListCellModel(leftView: img, middleView: label, rightView: imgRight)
        
        cell.setupCell(listCellModel)
        
        return cell 
    }

}