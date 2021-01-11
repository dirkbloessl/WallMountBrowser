import UIKit
import BLTNBoard

@objc public class URLFieldBulletinPage: BLTNPageItem {

    @objc public var textField: UITextField!

    @objc public var textInputHandler: ((URLFieldBulletinPage, String?) -> Void)? = nil

    override public func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        textField = interfaceBuilder.makeTextField(placeholder: "https://example.com", returnKey: .done, delegate: self)
        textField.keyboardType = UIKeyboardType.URL
        textField.textContentType = UITextContentType.URL;
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.spellCheckingType = .no
        return [textField]
    }

    override public func tearDown() {
        super.tearDown()
        textField?.delegate = nil
    }

    override public func actionButtonTapped(sender: UIButton) {
        textField.resignFirstResponder()
        super.actionButtonTapped(sender: sender)
    }

}


extension URLFieldBulletinPage: UITextFieldDelegate {
    
    @objc open func isInputValid(text: String?) -> Bool {
        if(text != nil) {
            if let urlString = text {
                if let url = NSURL(string: urlString) {
                    return UIApplication.shared.canOpenURL(url as URL)
                }
            }
        }
        return false
    }

    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {

        if isInputValid(text: textField.text) {
            descriptionLabel!.textColor = .black
            textField.backgroundColor = .none
            descriptionLabel!.text = NSLocalizedString("Which URL should be shown by Wall Mount Browser?", comment: "")
            textInputHandler?(self, textField.text)
        } else {
            descriptionLabel!.textColor = .red
            descriptionLabel!.text = NSLocalizedString("The entered URL is invalid or not reachable.", comment: "")
            textField.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        }

    }

}
