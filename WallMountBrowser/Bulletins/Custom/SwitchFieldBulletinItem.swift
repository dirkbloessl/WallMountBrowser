import UIKit
import BLTNBoard


@objc public class SwitchFieldBLTNItem: BLTNPageItem {
    public lazy var switchField = UISwitch()

    /**
     * Display the switch under the description label.
     */
    
    override public func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        switchField.isOn = true
    
        return [switchField]
    }
}
