//
//  FloatWindowManager.swift
//  Smaapper
//
//  Created by Alessandro Comparini on 01/06/23.
//

import UIKit

protocol FloatManagerDelegate: AnyObject {
    
    func viewDidLoad(_ floatWindow: FloatViewController)
    func viewWillAppear(_ floatWindow: FloatViewController)
    func viewWillLayoutSubviews(_ floatWindow: FloatViewController)
    func viewDidLayoutSubviews(_ floatWindow: FloatViewController)
    func viewDidAppear(_ floatWindow: FloatViewController)
    func viewWillDrag(_ floatWindow: FloatViewController)
    func viewDragging(_ floatWindow: FloatViewController)
    func viewDidDrag(_ floatWindow: FloatViewController)
    func viewMinimized(_ floatWindow: FloatViewController)
    func viewRestored(_ floatWindow: FloatViewController)
    func viewActivated(_ floatWindow: FloatViewController)
    func viewDesactivated(_ floatWindow: FloatViewController)
    func viewWillDisappear(_ floatWindow: FloatViewController)
    func viewDidDisappear(_ floatWindow: FloatViewController)
    
    
    func allClosedWindows()
    
}

class FloatManager {
    static let instance = FloatManager()
    
    weak var delegate: FloatManagerDelegate?
    
    private var _listWindows: [FloatViewController] = []
    private var _activeWindow: FloatViewController?
    private var _lastActiveWindow: FloatViewController?
    private var _desactivateWindowSuperViewControl: Bool = false
    
    private init() {}

    var listWindows: [FloatViewController] { self._listWindows }
    var countWindows: Int { self._listWindows.count }
    
    var lastActiveWindow: FloatViewController? {
        get { self._lastActiveWindow }
        set { self._lastActiveWindow = newValue }
    }
    
    var activeWindow: FloatViewController? {
        get { self._activeWindow }
        set { self._activeWindow = newValue }
    }
    
    func windowActive() -> FloatViewController? {
        return listWindows.first(where: { $0.active })
    }
    
    func addWindowToManager(_ floatWindow: FloatViewController)  {
        self._listWindows.append(floatWindow)
    }
    
    func removeWindowToManager(_ floatWindow: FloatViewController)  {
        self._listWindows.removeAll { $0.id == floatWindow.id }
    }
    
    func minimizeAll() {
        self._listWindows.forEach { win in
            win.viewMinimized()
        }
    }
    
    func restoreAll() {
        self._listWindows.forEach { win in
            win.viewRestored()
        }
    }
    
    func setDelegate(_ delegate: FloatManagerDelegate) {
        self.delegate = delegate
    }
    
    func getIndexById(_ id: UUID) -> Int? {
        if let index = listWindows.firstIndex(where: { $0.id == id }) {
            return index
        }
        return nil
    }
    

//  MARK: - PRIVATE Area
    
    
    func verifyAllClosedWindows() {
        if self.countWindows == 0 {
            delegate?.allClosedWindows()
        }
    }
    
        
    func configDesactivateWindowWhenTappedSuperView(_ superView: UIView) {
        if self._desactivateWindowSuperViewControl { return }
        
        superView.isUserInteractionEnabled = true
        TapGestureBuilder(superView)
            .setTouchEnded { [weak self] tapGesture in
                self?.windowActive()?.viewDesactivated()
                self?.lastActiveWindow?.viewDesactivated()
            }
        _desactivateWindowSuperViewControl = true
    }
    

}


extension FloatManagerDelegate {
    func viewDidLoad(_ floatWindow: FloatViewController) {}
    func viewWillAppear(_ floatWindow: FloatViewController) {}
    func viewWillLayoutSubviews(_ floatWindow: FloatViewController) {}
    func viewDidLayoutSubviews(_ floatWindow: FloatViewController) {}
    func viewDidAppear(_ floatWindow: FloatViewController) {}
    func viewWillDrag(_ floatWindow: FloatViewController) {}
    func viewDragging(_ floatWindow: FloatViewController) {}
    func viewDidDrag(_ floatWindow: FloatViewController) {}
    func viewMinimized(_ floatWindow: FloatViewController) {}
    func viewRestored(_ floatWindow: FloatViewController) {}
    func viewWillDisappear(_ floatWindow: FloatViewController) {}
    func viewDidDisappear(_ floatWindow: FloatViewController) {}
    func allClosedWindows() {}
}

