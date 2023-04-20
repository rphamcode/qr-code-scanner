//
//  WebView.swift
//  qr-code-scanner
//
//  Created by Pham on 4/20/23.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
      let url: URL
    
      func makeUIView(context: Context) -> WKWebView {
            let webView = WKWebView()
            webView.load(URLRequest(url: url))
            
            return webView
      }
      
      func updateUIView(_ uiView: WKWebView, context: Context) {
            // no updates needed
      }
}
