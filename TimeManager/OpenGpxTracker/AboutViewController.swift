//
//  InfoWKViewController.swift
//  OpenGpxTracker
//
//  Created by merlos on 24/09/14.
//

import UIKit
//import WebKit //<-- To support ios7 UIWebview will be used


///
/// Controller to display the About page.
///
/// Internally it is a UIWebView that displays the resource file about.html.
///
class AboutViewController: UIViewController, UIWebViewDelegate {
    
    /// Embedded web browser
    var webView: UIWebView?
    
    /// Initializer. Only calls super
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Initializer. Only calls super
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    ///
    /// Configures the view. Performs the following actions:
    ///
    /// 1. Sets the title to About
    /// 2. Adds "Done" button
    /// 3. Adds the webview that loads about.html from the bundle.
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "About"
        
        //Add the done button
        let shareItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(AboutViewController.closeViewController))
        self.navigationItem.rightBarButtonItems = [shareItem]
  
        //Add the Webview
        self.webView = UIWebView(frame: self.view.frame)
        self.webView?.delegate = self
        let path = Bundle.main.path(forResource: "about", ofType: "html")
        let text = try? String(contentsOfFile: path!, encoding: String.Encoding.utf8)
        
        webView?.loadHTMLString(text!, baseURL: nil)
        self.view.addSubview(webView!)
    }
    
    /// Opens Safari when user clicks a link in the About page.
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        print("shouldStartLoadWithRequest")
        
        if navigationType == UIWebView.NavigationType.linkClicked {
            UIApplication.shared.openURL(request.url!)
            return false
        }
        return true
    }
    
    /// Closes this view controller. Triggered by pressing the "Done" button in navigation bar.
    @objc func closeViewController() {
        self.dismiss(animated: true, completion: { () -> Void in
            
        })
    }
    
}
