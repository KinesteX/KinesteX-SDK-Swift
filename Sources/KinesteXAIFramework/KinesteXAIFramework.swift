
import SwiftUI
import WebKit

public enum WebViewMessage {
    case kinestexLaunched(String)
    case finishedWorkout(String)
    case errorOccurred(String)
    case exerciseCompleted(String)
    case exitApp(String)
    case workoutOpened(String)
    case workoutStarted(String)
    case planUnlocked(String)
    case unknown(String) // For handling any unrecognized messages
}

// Define a single SwiftUI view for both iOS and macOS
public struct KinesteXAIFramework: View {
    let apiKey: String
    let companyName: String
    let userId: String
    let planCategory: String
    let workoutCategory: String
    @Binding var isLoading: Bool
    var onMessageReceived: (WebViewMessage) -> Void

    public init(apiKey: String, companyName: String, userId: String, planCategory: String, workoutCategory: String, isLoading: Binding<Bool>, onMessageReceived: @escaping (WebViewMessage) -> Void) {
        self.apiKey = apiKey
        self.companyName = companyName
        self.userId = userId
        self.planCategory = planCategory
        self.workoutCategory = workoutCategory
        self._isLoading = isLoading
        self.onMessageReceived = onMessageReceived
    }
    
    public var body: some View {
        #if os(iOS)
        WebViewWrapperiOS(url: URL(string: "https://kineste-x-w.vercel.app")!, apiKey: apiKey, companyName: companyName, userId: userId, planCategory: planCategory, workoutCategory: workoutCategory,isLoading: $isLoading, onMessageReceived: onMessageReceived)
        #else
        WebViewWrappermacOS(url: URL(string: "https://kineste-x-w.vercel.app")!, apiKey: apiKey, companyName: companyName, userId: userId, planCategory: planCategory, workoutCategory: workoutCategory, isLoading: $isLoading, onMessageReceived: onMessageReceived)
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
    let planCategory: String
    let workoutCategory: String
    
    @Binding var isLoading: Bool
    var onMessageReceived: (WebViewMessage) -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, onMessageReceived: onMessageReceived)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        let parent: WebViewWrapperiOS
        var onMessageReceived: (WebViewMessage) -> Void
        
        init(parent: WebViewWrapperiOS, onMessageReceived: @escaping (WebViewMessage) -> Void) {
            self.parent = parent
            self.onMessageReceived = onMessageReceived
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            
            let script = """
            window.postMessage({
                'key': '\(parent.apiKey)',
                'company': '\(parent.companyName)',
                'userId': '\(parent.userId)',
                'planC': '\(parent.planCategory)',
                'category': '\(parent.workoutCategory)'
                              
            });
            """
            webView.evaluateJavaScript(script) { (result, error) in
                if let error = error {
                    DispatchQueue.main.async {
                        self.onMessageReceived(.errorOccurred("Cannot send data"))
                    }
                }
            }
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
               guard let messageBody = message.body as? String else { return }
               handle(message: messageBody)
           }
           
           func handle(message: String) {
               guard let data = message.data(using: .utf8),
                     let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                     let type = json["type"] as? String else {
                   print("Could not parse JSON message from WebView.")
                   return
               }
               
               let messageData = json["data"] as? String ?? ""
               
               // Using the currentTime function as described, ensure it's defined or adjust as needed
               
               let webViewMessage: WebViewMessage
               switch type {
               case "kinestex_launched":
                   webViewMessage = .kinestexLaunched(messageData)
               case "finished_workout":
                   webViewMessage = .finishedWorkout("\(messageData)")
               case "error_occured":
                   webViewMessage = .errorOccurred("\(messageData)")
               case "exercise_completed":
                   webViewMessage = .exerciseCompleted("\(messageData)")
               case "exitApp":
                   webViewMessage = .exitApp("User closed workout window")
               case "workoutOpened":
                   webViewMessage = .workoutOpened(messageData)
               case "workoutStarted":
                   webViewMessage = .workoutStarted(messageData)
               case "plan_unlocked":
                   webViewMessage = .planUnlocked(messageData)
               default:
                   webViewMessage = .unknown("Unknown message type: \(type) with data: \(messageData)")
               }
               
               DispatchQueue.main.async {
                   self.onMessageReceived(webViewMessage)
               }
           }
           
       
    }
}
#endif

// iOS specific wrapper

#if canImport(AppKit)
import AppKit

struct WebViewWrappermacOS: NSViewRepresentable {
    let url: URL
    let apiKey: String
    let companyName: String
    let userId: String
    let planCategory: String
    let workoutCategory: String
    
    @Binding var isLoading: Bool
    var onMessageReceived: (WebViewMessage) -> Void
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, onMessageReceived: onMessageReceived)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        let parent: WebViewWrappermacOS
        var onMessageReceived: (WebViewMessage) -> Void
        
        init(parent: WebViewWrappermacOS, onMessageReceived: @escaping (WebViewMessage) -> Void) {
            self.parent = parent
            self.onMessageReceived = onMessageReceived
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            let script = """
            window.postMessage({
                'key': '\(parent.apiKey)',
                'company': '\(parent.companyName)',
                'userId': '\(parent.userId)',
                'planC': '\(parent.planCategory)',
                'category': '\(parent.workoutCategory)'
                              
            });
            """
            webView.evaluateJavaScript(script) { (result, error) in
                if let error = error {
                    DispatchQueue.main.async {
                        self.onMessageReceived(.errorOccurred("Cannot send data"))
                    }
                }
            }
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
               guard let messageBody = message.body as? String else { return }
               handle(message: messageBody)
           }
           
           func handle(message: String) {
               guard let data = message.data(using: .utf8),
                     let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                     let type = json["type"] as? String else {
                   print("Could not parse JSON message from WebView.")
                   return
               }
               
               let messageData = json["data"] as? String ?? ""
               
               // Using the currentTime function as described, ensure it's defined or adjust as needed
               
               let webViewMessage: WebViewMessage
               switch type {
               case "kinestex_launched":
                   webViewMessage = .kinestexLaunched(messageData)
               case "finished_workout":
                   webViewMessage = .finishedWorkout("\(messageData)")
               case "error_occured":
                   webViewMessage = .errorOccurred("\(messageData)")
               case "exercise_completed":
                   webViewMessage = .exerciseCompleted("\(messageData)")
               case "exitApp":
                   webViewMessage = .exitApp("User closed workout window")
               case "workoutOpened":
                   webViewMessage = .workoutOpened(messageData)
               case "workoutStarted":
                   webViewMessage = .workoutStarted(messageData)
               case "plan_unlocked":
                   webViewMessage = .planUnlocked(messageData)
               default:
                   webViewMessage = .unknown("Unknown message type: \(type) with data: \(messageData)")
               }
               
               DispatchQueue.main.async {
                   self.onMessageReceived(webViewMessage)
               }
           }
           
    }
}
#endif


