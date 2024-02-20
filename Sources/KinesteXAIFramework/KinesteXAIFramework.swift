
import SwiftUI
import WebKit

// Define a single SwiftUI view for both iOS and macOS
public struct KinesteXAIFramework: View {
    let apiKey: String
    let companyName: String
    let userId: String
    @Binding var isLoading: Bool

    public init(apiKey: String, companyName: String, userId: String, isLoading: Binding<Bool>) {
        self.apiKey = apiKey
        self.companyName = companyName
        self.userId = userId
        self._isLoading = isLoading
    }
    
    public var body: some View {
        #if os(iOS)
        WebViewWrapperiOS(url: URL(string: "https://kineste-x-w.vercel.app")!, apiKey: apiKey, companyName: companyName, userId: userId, isLoading: $isLoading)
        #else
        WebViewWrappermacOS(url: URL(string: "https://kineste-x-w.vercel.app")!, apiKey: apiKey, companyName: companyName, userId: userId, isLoading: $isLoading)
        #endif
    }
}

#if canImport(UIKit)
import UIKit
struct WebViewWrapperiOS: UIViewRepresentable {
    let url: URL
    let apiKey: String
    let companyName: String
    let userId: String
    @Binding var isLoading: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        let parent: WebViewWrapperiOS
        
        init(parent: WebViewWrapperiOS) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            let script = """
            window.postMessage({
                'key': '\(parent.apiKey)',
                'company': '\(parent.companyName)',
                'userId': '\(parent.userId)',
                'planC': 'Cardio',
            });
            """
            // pass the values
            webView.evaluateJavaScript(script) { (result, error) in
                if let error = error {
                    print("JavaScript error: \(error)")
                }
            }
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            // Handle received messages here
        }
    }
}
#endif
// iOS specific wrapper

#if canImport(AppKit)
import AppKit
// macOS specific wrapper
struct WebViewWrappermacOS: NSViewRepresentable {
    let url: URL
    let apiKey: String
    let companyName: String
    let userId: String
    @Binding var isLoading: Bool
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        let parent: WebViewWrappermacOS
        
        init(parent: WebViewWrappermacOS) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            let script = "window.postMessage({'apiKey': '\(parent.apiKey)', 'companyName': '\(parent.companyName)', 'userId': '\(parent.userId)'});"
            webView.evaluateJavaScript(script, completionHandler: nil)
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            // Handle received messages here
        }
    }
}

#endif

