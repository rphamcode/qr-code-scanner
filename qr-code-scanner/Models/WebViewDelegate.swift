//
//  WebViewDelegate.swift
//  qr-code-scanner
//
//  Created by Pham on 4/20/23.
//

import Foundation
import WebKit

class WebViewDelegate: NSObject, ObservableObject, WKNavigationDelegate {
      @Published var canGoBack: Bool = false
      
      func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            canGoBack = webView.canGoBack
      }
      
      func goBack(webView: WKWebView) {
            if webView.canGoBack {
                  webView.goBack()
            }
      }
}
