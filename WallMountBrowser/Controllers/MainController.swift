import UIKit
import WebKit
import BLTNBoard


class MainController: UIViewController, WKNavigationDelegate, UIGestureRecognizerDelegate {

    @IBOutlet var webViewContainer: UIView!

    var webView: WKWebView!
    var activityIndicator: UIActivityIndicatorView!

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

        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        
        webView = WKWebView(frame: self.view.frame, configuration: webConfiguration)
        webView.navigationDelegate = self
    
        webViewContainer.addSubview(webView)

        activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .whiteLarge
        activityIndicator.color = .gray
        activityIndicator.isHidden = true
        
        webViewContainer.addSubview(activityIndicator)
        
        NotificationCenter.default.addObserver(self,
           selector: #selector(MainController.defaultsChanged),
           name: UserDefaults.didChangeNotification,
           object: nil
        )
        if(BulletinDataSource.userDidCompleteSetup) {
            defaultsChanged()
        }

        //let myApp = UIApplication.shared as? WallMountBrowserApplication
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
            webView.load(URLRequest(url: url, timeoutInterval: 10))
            self.setNeedsStatusBarAppearanceUpdate();
        }
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

    /*
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {

        if let response = navigationResponse.response as? HTTPURLResponse {
            if response.statusCode == 404 {
                let alert = UIAlertController(title: "My Alert", message: "This is an alert.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        decisionHandler(.allow)
    }
    */
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error)
    {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true

        let nsError = error as NSError
        print ("NSError.code: \(nsError.code)")
        if let myError = error as? URLError
        {
            let failureUrlString = myError.failureURLString ?? "unknown failure URL"
            print("URLError: Reason: \(myError.localizedDescription)")
            print("URLError: Failing URL: \(failureUrlString)")
            
            let alert = UIAlertController(title: "Error opening the URL",
                                          message: "URL: \(failureUrlString)\n\n" +
                                                   "Error: \(myError.localizedDescription)\n\n" +
                                                   "Please check the entered URL.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Go to settings", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"Go to settings\" action was chosen.")
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" action was chosen.")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
}
