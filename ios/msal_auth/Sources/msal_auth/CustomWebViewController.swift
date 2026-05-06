import MSAL

/// Creates custom webview controller to manage customized webview.
/// - Parameters:
///   - config: Configuration for custom webview.
class CustomWebviewController: UIViewController, WKUIDelegate,
    WKNavigationDelegate
{
    private var webView: WKWebView!
    private var config: [String: Any]

    // Store references to navigation buttons
    private var backButton: UIBarButtonItem?
    private var forwardButton: UIBarButtonItem?

    init(config: [String: Any]) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func getWebView() -> WKWebView {
        return webView
    }

    // Status bar configuration
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Force light theme in view
        view.backgroundColor = .white

        // Adding navigation bar
        let navigationBar = UINavigationBar()
        navigationBar.translatesAutoresizingMaskIntoConstraints = false

        // Configure navigation bar appearance for light theme
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.shadowColor = UIColor.white

        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance

        view.addSubview(navigationBar)

        // Adding title and cancel button in navigation bar
        let navigationItem = UINavigationItem()
        navigationItem.title = config["title"] as? String
        let cancelButton = UIBarButtonItem(
            title: config["cancelButtonTitle"] as? String,
            style: .plain,
            target: self,
            action: #selector(closeWebView)
        )
        navigationItem.leftBarButtonItem = cancelButton

        // Add navigation controls if enabled
        let showNavigationControls =
            config["showNavigationControls"] as? Bool ?? false
        if showNavigationControls {
            backButton = UIBarButtonItem(
                image: UIImage(systemName: "chevron.left"),
                style: .plain,
                target: self,
                action: #selector(goBack)
            )
            forwardButton = UIBarButtonItem(
                image: UIImage(systemName: "chevron.right"),
                style: .plain,
                target: self,
                action: #selector(goForward)
            )

            backButton?.isEnabled = false
            forwardButton?.isEnabled = false

            navigationItem.rightBarButtonItems = [forwardButton!, backButton!]
        }

        navigationBar.setItems([navigationItem], animated: false)

        // Navigation constraint
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
        ])

        // Set up webview configuration
        let webViewConfiguration = WKWebViewConfiguration()

        // Initialize webview
        webView = WKWebView(
            frame: view.bounds,
            configuration: webViewConfiguration
        )
        webView.uiDelegate = self
        webView.navigationDelegate = self

        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false

        // Webview constraint
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
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
        // Set up observers for webview navigation state
        webView.addObserver(
            self,
            forKeyPath: "canGoBack",
            options: .new,
            context: nil
        )
        webView.addObserver(
            self,
            forKeyPath: "canGoForward",
            options: .new,
            context: nil
        )

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
        webView.removeObserver(self, forKeyPath: "canGoBack")
        webView.removeObserver(self, forKeyPath: "canGoForward")

        NotificationCenter.default.removeObserver(self)
    }

    /// Handle changes in webview navigation state
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == "canGoBack" {
            backButton?.isEnabled = webView.canGoBack
        } else if keyPath == "canGoForward" {
            forwardButton?.isEnabled = webView.canGoForward
        }
    }

    // MARK: - Webview functions

    @objc func closeWebView() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func goBack() {
        webView.goBack()
    }

    @objc private func goForward() {
        webView.goForward()
    }

    // MARK: - Notification handler functions

    @objc func handleWebAuthDidFail() {
        closeWebView()
    }

    @objc func handleWebAuthDidComplete() {
        closeWebView()
    }
}
