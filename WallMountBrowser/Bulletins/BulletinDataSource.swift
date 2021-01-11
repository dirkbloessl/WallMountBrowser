import UIKit
import BLTNBoard
import SafariServices


enum BulletinDataSource {

    static func makeIntroPage() -> BLTNPageItem {

        let page = BLTNPageItem(title: "Wall Mount Browser")
        page.appearance = BLTNItemAppearance()
        page.image = UIImage(named: "BulletinIcon")
        
        page.descriptionText = NSLocalizedString("Welcome! We need to configure the basic information for using the app first.", comment: "")
        page.actionButtonTitle = NSLocalizedString("Go", comment: "")
        page.alternativeButtonTitle = nil

        page.isDismissable = false
        page.shouldStartWithActivityIndicator = true

        page.presentationHandler = { item in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                item.manager?.hideActivityIndicator()
            }
        }

        page.actionHandler = { item in
            item.manager?.displayNextItem()
        }
        page.next = makeURLPage()

        return page

    }

    /**
        
     */
    static func makeURLPage() -> URLFieldBulletinPage {

        let page = URLFieldBulletinPage(title: NSLocalizedString("Enter the URL", comment: ""))
        page.isDismissable = false
        page.imageAccessibilityLabel = "App Icon"
        page.descriptionText = NSLocalizedString("Which URL should be shown by Wall Mount Browser?", comment: "")
        page.actionButtonTitle = NSLocalizedString("Next", comment: "")

        page.textInputHandler = { (item, text) in
            UserDefaults.standard.set(text, forKey: SettingsBundleHelper.SettingsBundleKeys.Url)
            let nextPage = self.makeHideStatusBarPage()
            item.manager?.push(item: nextPage)
        }

        return page

    }
    
    static func makeHideStatusBarPage() -> BLTNPageItem {

        let page = SwitchFieldBLTNItem(title: NSLocalizedString("Hide the status bar?", comment: ""))
        page.descriptionText = NSLocalizedString("Do you want to hide the status bar and show the browser in full screen?", comment: "")
        page.isDismissable = false
        page.actionButtonTitle = NSLocalizedString("Next", comment: "")

        page.actionHandler = { item in
            print(page.switchField.isOn)
            item.manager?.displayNextItem()
        }

        page.next = makeCompletionPage()

        return page

    }
    
    static func makeCompletionPage() -> BLTNPageItem {

        let page = BLTNPageItem(title: NSLocalizedString("Setup Completed", comment: ""))
        page.imageAccessibilityLabel = "Checkmark"
        page.image = UIImage(named: "IntroCompletion")
        let tintColor: UIColor
        if #available(iOS 13.0, *) {
            tintColor = .systemGreen
        } else {
            tintColor = #colorLiteral(red: 0.2980392157, green: 0.8509803922, blue: 0.3921568627, alpha: 1)
        }
        page.appearance.actionButtonColor = tintColor
        page.appearance.imageViewTintColor = tintColor

        page.appearance.actionButtonTitleColor = .white

        page.descriptionText = NSLocalizedString("Wall Mount Browser is ready to use. The settings can be adjusted in the Settings App.", comment: "")
        page.actionButtonTitle = NSLocalizedString("Finish", comment: "")

        page.isDismissable = true

        page.dismissalHandler = { item in
            userDidCompleteSetup = true
        }

        page.actionHandler = { item in
            item.manager?.dismissBulletin(animated: true)
        }

        return page

    }
    
    /// Whether user completed setup.
    static var userDidCompleteSetup: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "WallMountBrowserUserDidCompleteSetup")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "WallMountBrowserUserDidCompleteSetup")}
    }

}
