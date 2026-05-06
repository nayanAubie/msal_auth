import MSAL

/// Creates custom webview controller to manage customized webview.
class CustomWebviewController: NSViewController, WKUIDelegate,
    WKNavigationDelegate
{
    private var webView: WKWebView!

    func getWebView() -> WKWebView {
        return webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the main view
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor

        // Set up webview configuration
        let webViewConfiguration = WKWebViewConfiguration()

        // Initialize webview
        webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self

        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false

        // Webview constraint
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        // Listeners for webview activity
        addObservers()
    }

    deinit {
        // Remove observers to prevent memory leaks
        removeObservers()
        // Cancel MSAL session
        MSALPublicClientApplication.cancelCurrentWebAuthSession()
    }

    /// Listeners setup to manage webview on specific actions received by MSAL WebView.
    private func addObservers() {
        // Observers for MSAL actions
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWebAuthDidFail),
            name: NSNotification.Name("MSALWebAuthDidFailNotification"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWebAuthDidComplete),
            name: NSNotification.Name("MSALWebAuthDidCompleteNotification"),
            object: nil
        )
    }

    /// Remove all added observers on dispose.
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Webview functions

    @objc func closeWebView() {
        self.presentingViewController?.dismiss(self)
    }

    // MARK: - Notification handler functions

    @objc func handleWebAuthDidFail() {
        closeWebView()
    }

    @objc func handleWebAuthDidComplete() {
        closeWebView()
    }
}
