import UIKit
import WebKit
import BLTNBoard


class MainController: UIViewController, WKNavigationDelegate, UIGestureRecognizerDelegate {

    @IBOutlet var webView: WKWebView!

    lazy var bulletinManager: BLTNItemManager = {
        let introPage = BulletinDataSource.makeIntroPage()
        return BLTNItemManager(rootItem: introPage)
    }()

    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if !BulletinDataSource.userDidCompleteSetup {
            UserDefaults.standard.setValue(true, forKey: SettingsBundleHelper.SettingsBundleKeys.HideStatusBar)
            UserDefaults.standard.setValue(60, forKey: SettingsBundleHelper.SettingsBundleKeys.Timeout)
            showBulletin()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
           selector: #selector(MainController.defaultsChanged),
           name: UserDefaults.didChangeNotification,
           object: nil
        )
        if(BulletinDataSource.userDidCompleteSetup) {
            defaultsChanged()
        }
    }
    
    func showBulletin() {
        reloadManager()
        bulletinManager.backgroundViewStyle = BLTNBackgroundViewStyle.blurredDark
        bulletinManager.statusBarAppearance = BLTNStatusBarAppearance.hidden;
        bulletinManager.showBulletin(above: self)

        self.setNeedsStatusBarAppearanceUpdate();

    }

    func reloadManager() {
        let introPage = BulletinDataSource.makeIntroPage()
        bulletinManager = BLTNItemManager(rootItem: introPage)
    }
    
    func loadUrl()
    {
        let urlString = UserDefaults.standard.string(forKey: SettingsBundleHelper.SettingsBundleKeys.Url)
        if (urlString != nil && BulletinDataSource.userDidCompleteSetup) {
            let url = URL(string: urlString!)!
            webView.load(URLRequest(url: url))
            self.setNeedsStatusBarAppearanceUpdate();
        }
    }
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    @objc func defaultsChanged() {
        loadUrl()
        self.setNeedsStatusBarAppearanceUpdate();
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return UserDefaults.standard.bool(forKey: SettingsBundleHelper.SettingsBundleKeys.HideStatusBar)
        }
    }

}
