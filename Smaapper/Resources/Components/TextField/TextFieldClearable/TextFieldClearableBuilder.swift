//
//  TextFieldClearableBuilder.swift
//  Smaapper
//
//  Created by Alessandro Comparini on 05/07/23.
//

import UIKit

class TextFieldClearableBuilder: TextFieldImageBuilder {
    
    init(paddingRightImage: CGFloat = C.TextFieldPassword.paddingRight) {
        super.init(image: ImageViewBuilder(UIImage(systemName: "eye.slash")).view,
                   position: .right,
                   margin: paddingRightImage)
//            .setOnTapImage(completion: openCloseEyes(_:))
    }
    
    convenience init(_ placeHolder: String) {
        self.init()
        super.setPlaceHolder(placeHolder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
//  MARK: - ACTIONS THIS COMPONENT

    private func openCloseEyes(_ imageView: UIImageView) {
        
    }
    
}
