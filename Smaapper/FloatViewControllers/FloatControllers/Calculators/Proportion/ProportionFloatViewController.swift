//
//  ProportionFloatViewController.swift
//  Smaapper
//
//  Created by Alessandro Comparini on 12/06/23.
//

import UIKit

class ProportionFloatViewController: FloatViewController {
    static let identifierApp = K.Proportion.identifierApp
    
    private var proportionA: Double = .zero
    private var proportionB: Double = .zero
    private var proportionC: Double = .zero
    private var resultProportion: Double = .zero
    
    lazy var screen: ProportionView = {
        let view = ProportionView()
        return view
    }()
    
    override func loadView() {
        view = screen.view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setFrameWindow(CGRect(x: K.Proportion.FloatView.x,
                              y: K.Proportion.FloatView.y,
                              width: K.Proportion.FloatView.width,
                              height: K.Proportion.FloatView.height))
        setEnabledDraggable(true)
        configDelegate()
    }
    
    override func viewDidSelectFloatView() {
        super.viewDidSelectFloatView()
        UtilsFloatView.setShadowActiveFloatView(screen)
    }
    
    override func viewDidDeselectFloatView() {
        super.viewDidDeselectFloatView()
        UtilsFloatView.removeShadowActiveFloatView(screen)
    }
    
    
//  MARK: - PRIVATE Area
    
    private func configDelegate() {
        screen.delegate = self
        screen.setTextFieldDelegate(self)
        screen.setPainelDelegate(self)
    }
    
    private func calculateResult() {
        getNumbersForCalculate()
        if !isValidFields() {
            presentResult(.zero)
            return
        }
        let result = (proportionC * proportionB) / proportionA
        presentResult(result)
        showStackButtons()
    }
    
    private func presentResult(_ result: Double) {
        if result == .zero {
            restartResult()
            return
        }
        let formattedResult = NumberFormatterBuilder().setMaximumFractionDigits(K.Proportion.maxDigits).getString(result)
        screen.painel.resultLabel.setText(formattedResult ?? K.Proportion.displayZero)
    }
    
    private func isValidFields() -> Bool {
        if isFieldsEmpty() || proportionA == .zero {
            return false
        }
        return true
    }
    
    private func isFieldsEmpty() -> Bool {
        if let textFieldEmpty = screen.painel.listTextFields.first(where: { ($0.text?.isEmpty) ?? false }) {
            textFieldEmpty.becomeFirstResponder()
            return true
        }
        return false
    }
    
    private func getNumbersForCalculate() {
        proportionA = screen.painel.textFieldA.getNumber.doubleValue
        proportionB = screen.painel.textFieldB.getNumber.doubleValue
        proportionC = screen.painel.textFieldC.getNumber.doubleValue
    }
    
    private func getDoubleValueOfTextField(_ text: String?) -> Double {
        if var textResult = text {
            if Utils.decimalSeparator != K.dot {
                textResult = textResult.replacingOccurrences(of: K.dot, with: K.stringEmpty)
            }
            return Double(textResult.replacingOccurrences(of: Utils.decimalSeparator, with: K.dot)) ?? .zero
        }
        return .zero
    }
    
    private func showStackButtons() {
        screen.okButton.setHidden(true)
        screen.stackViewButtons.setHidden(false)
    }
    
    private func showOkButton() {
        screen.okButton.setHidden(false)
        screen.stackViewButtons.setHidden(true)
    }
    
    private func clearTextFields() {
        screen.painel.listTextFields.forEach { textField in
            textField.text = K.stringEmpty
        }
    }
    
    private func restartResult() {
        screen.painel.resultLabel.setText(K.Proportion.displayZero)
    }
    
}


//  MARK: - EXTENSION ProportionViewDelegate

extension ProportionFloatViewController: ProportionViewDelegate {

    func closeWindow() {
        self.dismiss()
    }
    
    func minimizeWindow() {
        self.minimize
    }
    
    func okButton() {
        calculateResult()
    }

    func copyButton() {
        UIPasteboard.general.string = screen.painel.resultLabel.view.text
    }
    
    func refreshButton() {
        showOkButton()
        clearTextFields()
        restartResult()
        screen.painel.textFieldA.setFocus()
    }
        
}


//  MARK: - EXTENSION TextFieldDelegate
extension ProportionFloatViewController: TextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: TextField) {
        self.select
    }
    
    func textField(_ textField: TextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        showOkButton()
        return true
    }
    
}


//  MARK: - EXTENSION PainelProportionViewDelegate
extension ProportionFloatViewController: PainelProportionViewDelegate {
    
    func doneKeyboard(_ textField: UITextField) {
        calculateResult()
        self.view.endEditing(true)
    }
    
    
}
